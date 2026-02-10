from flask import Flask, render_template, request, send_file, jsonify
import os
import uuid
from werkzeug.utils import secure_filename
import subprocess
from PIL import Image
import io
from ncm_decrypt import decrypt_ncm_to_format, get_ncm_metadata

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 500 * 1024 * 1024  # 500MB max file size
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['OUTPUT_FOLDER'] = 'outputs'

# 创建必要的文件夹
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
os.makedirs(app.config['OUTPUT_FOLDER'], exist_ok=True)

# 支持的格式
AUDIO_FORMATS = ['mp3', 'wav', 'aac', 'flac', 'ogg', 'wma', 'm4a', 'opus']
VIDEO_FORMATS = ['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'webm', 'mpeg', 'mpg']
IMAGE_FORMATS = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'ico', 'tiff']
NCM_FORMATS = ['ncm']  # 网易云音乐加密格式

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/convert', methods=['POST'])
def convert_file():
    try:
        if 'file' not in request.files:
            return jsonify({'error': '没有选择文件'}), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({'error': '文件名为空'}), 400
        
        output_format = request.form.get('format', '').lower()
        if not output_format:
            return jsonify({'error': '请选择输出格式'}), 400
        
        # 生成唯一文件名
        unique_id = str(uuid.uuid4())
        original_filename = secure_filename(file.filename)
        input_ext = original_filename.rsplit('.', 1)[1].lower() if '.' in original_filename else ''
        
        input_path = os.path.join(app.config['UPLOAD_FOLDER'], f"{unique_id}_input.{input_ext}")
        output_filename = f"{original_filename.rsplit('.', 1)[0]}.{output_format}"
        output_path = os.path.join(app.config['OUTPUT_FOLDER'], f"{unique_id}_output.{output_format}")
        
        # 保存上传的文件
        file.save(input_path)
        
        # 根据格式类型进行转换
        if input_ext == 'ncm':
            # 处理 NCM 格式
            convert_ncm(input_path, output_path, output_format)
        elif output_format in IMAGE_FORMATS:
            convert_image(input_path, output_path, output_format)
        elif output_format in AUDIO_FORMATS or output_format in VIDEO_FORMATS:
            convert_media(input_path, output_path, output_format)
        else:
            return jsonify({'error': '不支持的输出格式'}), 400
        
        # 返回转换后的文件
        response = send_file(
            output_path,
            as_attachment=True,
            download_name=output_filename
        )
        
        # 清理临时文件（在发送响应后）
        @response.call_on_close
        def cleanup():
            try:
                if os.path.exists(input_path):
                    os.remove(input_path)
                if os.path.exists(output_path):
                    os.remove(output_path)
            except:
                pass
        
        return response
    
    except Exception as e:
        return jsonify({'error': f'转换失败: {str(e)}'}), 500

def convert_image(input_path, output_path, output_format):
    """转换图片格式"""
    with Image.open(input_path) as img:
        # 处理 PNG 转 JPG 时的透明通道
        if output_format in ['jpg', 'jpeg'] and img.mode in ('RGBA', 'LA', 'P'):
            background = Image.new('RGB', img.size, (255, 255, 255))
            if img.mode == 'P':
                img = img.convert('RGBA')
            background.paste(img, mask=img.split()[-1] if img.mode == 'RGBA' else None)
            img = background
        
        # 保存图片
        save_kwargs = {'quality': 95} if output_format in ['jpg', 'jpeg'] else {}
        img.save(output_path, format=output_format.upper(), **save_kwargs)

def convert_media(input_path, output_path, output_format):
    """使用 FFmpeg 转换音视频格式"""
    command = [
        'ffmpeg',
        '-i', input_path,
        '-y',  # 覆盖输出文件
        output_path
    ]
    
    # 针对特定格式添加参数
    if output_format in ['mp3']:
        command.insert(3, '-codec:a')
        command.insert(4, 'libmp3lame')
        command.insert(5, '-q:a')
        command.insert(6, '2')
    elif output_format in ['mp4']:
        command.insert(3, '-codec:v')
        command.insert(4, 'libx264')
        command.insert(5, '-codec:a')
        command.insert(6, 'aac')
    
    result = subprocess.run(command, capture_output=True, text=True)
    
    if result.returncode != 0:
        raise Exception(f'FFmpeg 错误: {result.stderr}')


def convert_ncm(input_path, output_path, output_format):
    """转换网易云音乐 NCM 格式"""
    try:
        # 解密 NCM 文件
        result = decrypt_ncm_to_format(input_path, output_path, output_format)
        
        # 如果返回的是元组，说明需要进一步转换
        if isinstance(result, tuple):
            temp_path, original_format = result
            # 使用 FFmpeg 转换格式
            convert_media(temp_path, output_path, output_format)
            # 清理临时文件
            if os.path.exists(temp_path):
                os.remove(temp_path)
    except Exception as e:
        raise Exception(f'NCM 转换失败: {str(e)}')

@app.route('/formats')
def get_formats():
    """返回支持的格式列表"""
    return jsonify({
        'audio': AUDIO_FORMATS,
        'video': VIDEO_FORMATS,
        'image': IMAGE_FORMATS,
        'ncm': NCM_FORMATS
    })


@app.route('/ncm-info', methods=['POST'])
def get_ncm_info():
    """获取 NCM 文件信息"""
    try:
        if 'file' not in request.files:
            return jsonify({'error': '没有选择文件'}), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({'error': '文件名为空'}), 400
        
        # 保存临时文件
        unique_id = str(uuid.uuid4())
        temp_path = os.path.join(app.config['UPLOAD_FOLDER'], f"{unique_id}_temp.ncm")
        file.save(temp_path)
        
        # 获取元数据
        metadata = get_ncm_metadata(temp_path)
        
        # 清理临时文件
        if os.path.exists(temp_path):
            os.remove(temp_path)
        
        return jsonify(metadata)
    
    except Exception as e:
        return jsonify({'error': f'获取信息失败: {str(e)}'}), 500

if __name__ == '__main__':
    app.run(debug=True, host='::', port=52113)
