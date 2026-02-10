"""
网易云音乐 NCM 格式解密模块
用于解密 .ncm 文件并转换为标准音频格式
"""
import struct
import binascii
import base64
import json
from Crypto.Cipher import AES
import os

# 核心密钥
CORE_KEY = binascii.a2b_hex("687A4852416D736F356B496E62617857")
META_KEY = binascii.a2b_hex("2331346C6A6B5F215C5D2630553C2728")


def unpad(data):
    """移除 PKCS7 填充"""
    return data[0:-data[-1]]


def decrypt_ncm_file(input_path, output_path=None):
    """
    解密 NCM 文件
    
    Args:
        input_path: NCM 文件路径
        output_path: 输出文件路径（可选）
    
    Returns:
        tuple: (解密后的数据, 元数据, 文件扩展名)
    """
    try:
        with open(input_path, 'rb') as f:
            # 验证文件头
            header = f.read(8)
            if header != b'CTENFDAM':
                raise ValueError('不是有效的 NCM 文件')
            
            f.seek(2, 1)  # 跳过 2 字节
            
            # 读取密钥数据
            key_length = struct.unpack('<I', f.read(4))[0]
            key_data = bytearray(f.read(key_length))
            
            # 解密密钥
            for i in range(len(key_data)):
                key_data[i] ^= 0x64
            
            # AES 解密密钥数据
            cipher = AES.new(CORE_KEY, AES.MODE_ECB)
            key_data = unpad(cipher.decrypt(bytes(key_data)))[17:]
            
            # 构建密钥盒
            key_box = bytearray(range(256))
            j = 0
            for i in range(256):
                j = (j + key_box[i] + key_data[i % len(key_data)]) & 0xff
                key_box[i], key_box[j] = key_box[j], key_box[i]
            
            # 读取元数据
            meta_length = struct.unpack('<I', f.read(4))[0]
            meta_data = bytearray(f.read(meta_length))
            
            # 解密元数据
            for i in range(len(meta_data)):
                meta_data[i] ^= 0x63
            
            meta_data = base64.b64decode(meta_data[22:])
            cipher = AES.new(META_KEY, AES.MODE_ECB)
            meta_data = unpad(cipher.decrypt(meta_data)).decode('utf-8')
            meta_json = json.loads(meta_data[6:])
            
            # 确定文件格式
            format_ext = meta_json.get('format', 'mp3')
            
            # 跳过 CRC32 和封面
            f.seek(5, 1)  # 跳过 CRC32
            image_size = struct.unpack('<I', f.read(4))[0]
            f.seek(image_size, 1)  # 跳过封面数据
            
            # 读取并解密音频数据
            audio_data = bytearray()
            while True:
                chunk = f.read(0x8000)
                if not chunk:
                    break
                
                chunk = bytearray(chunk)
                for i in range(len(chunk)):
                    j = (i + 1) & 0xff
                    k = key_box[(key_box[j] + key_box[(key_box[j] + j) & 0xff]) & 0xff]
                    chunk[i] ^= k
                
                audio_data.extend(chunk)
            
            # 如果指定了输出路径，保存文件
            if output_path:
                with open(output_path, 'wb') as out_f:
                    out_f.write(audio_data)
            
            return bytes(audio_data), meta_json, format_ext
            
    except Exception as e:
        raise Exception(f'NCM 文件解密失败: {str(e)}')


def decrypt_ncm_to_format(input_path, output_path, target_format=None):
    """
    解密 NCM 文件并转换为指定格式
    
    Args:
        input_path: NCM 文件路径
        output_path: 输出文件路径
        target_format: 目标格式（如果为 None，则使用原始格式）
    """
    # 解密文件
    audio_data, meta_json, original_format = decrypt_ncm_file(input_path)
    
    # 确定输出格式
    if target_format is None:
        target_format = original_format
    
    # 如果目标格式与原始格式相同，直接保存
    if target_format.lower() == original_format.lower():
        with open(output_path, 'wb') as f:
            f.write(audio_data)
        return output_path
    
    # 否则需要先保存为临时文件，再用 FFmpeg 转换
    temp_path = output_path + f'.temp.{original_format}'
    with open(temp_path, 'wb') as f:
        f.write(audio_data)
    
    return temp_path, original_format


def get_ncm_metadata(input_path):
    """
    获取 NCM 文件的元数据
    
    Args:
        input_path: NCM 文件路径
    
    Returns:
        dict: 元数据信息
    """
    try:
        _, meta_json, format_ext = decrypt_ncm_file(input_path)
        return {
            'format': format_ext,
            'musicName': meta_json.get('musicName', '未知'),
            'artist': meta_json.get('artist', [[0, '未知']]),
            'album': meta_json.get('album', '未知'),
            'bitrate': meta_json.get('bitrate', 0),
            'duration': meta_json.get('duration', 0)
        }
    except Exception as e:
        return {'error': str(e)}
