"""
测试 NCM 解密功能
用于验证 NCM 文件解密是否正常工作
"""
import os
from ncm_decrypt import get_ncm_metadata, decrypt_ncm_to_format

def test_ncm_decrypt():
    """测试 NCM 解密功能"""
    print("=" * 50)
    print("NCM 格式解密测试")
    print("=" * 50)
    
    # 检查是否有测试文件
    test_file = "test.ncm"
    
    if not os.path.exists(test_file):
        print(f"\n⚠️  未找到测试文件: {test_file}")
        print("请将一个 NCM 文件命名为 test.ncm 并放在当前目录")
        return
    
    print(f"\n📁 测试文件: {test_file}")
    print(f"📏 文件大小: {os.path.getsize(test_file) / 1024 / 1024:.2f} MB")
    
    # 测试获取元数据
    print("\n" + "-" * 50)
    print("1️⃣ 获取文件元数据...")
    print("-" * 50)
    
    try:
        metadata = get_ncm_metadata(test_file)
        
        if 'error' in metadata:
            print(f"❌ 获取元数据失败: {metadata['error']}")
            return
        
        print(f"✅ 成功获取元数据：")
        print(f"   🎵 歌曲名: {metadata.get('musicName', '未知')}")
        
        artists = metadata.get('artist', [])
        if artists and len(artists) > 0:
            artist_names = [artist[1] for artist in artists if len(artist) > 1]
            print(f"   🎤 歌手: {', '.join(artist_names)}")
        
        print(f"   💿 专辑: {metadata.get('album', '未知')}")
        print(f"   📊 码率: {metadata.get('bitrate', 0)} kbps")
        print(f"   ⏱️  时长: {metadata.get('duration', 0) / 1000:.2f} 秒")
        print(f"   📝 原始格式: {metadata.get('format', '未知').upper()}")
        
    except Exception as e:
        print(f"❌ 错误: {str(e)}")
        return
    
    # 测试解密转换
    print("\n" + "-" * 50)
    print("2️⃣ 测试解密转换...")
    print("-" * 50)
    
    output_format = "mp3"
    output_file = f"test_output.{output_format}"
    
    try:
        print(f"🔄 正在解密并转换为 {output_format.upper()} 格式...")
        
        result = decrypt_ncm_to_format(test_file, output_file, output_format)
        
        # 如果返回元组，说明需要进一步转换
        if isinstance(result, tuple):
            print(f"⚠️  需要格式转换: {result[1].upper()} → {output_format.upper()}")
            print("   (需要 FFmpeg 支持)")
        else:
            if os.path.exists(output_file):
                output_size = os.path.getsize(output_file) / 1024 / 1024
                print(f"✅ 转换成功！")
                print(f"   📁 输出文件: {output_file}")
                print(f"   📏 文件大小: {output_size:.2f} MB")
            else:
                print(f"❌ 输出文件未生成")
        
    except Exception as e:
        print(f"❌ 转换失败: {str(e)}")
        import traceback
        traceback.print_exc()
    
    print("\n" + "=" * 50)
    print("测试完成")
    print("=" * 50)


if __name__ == "__main__":
    test_ncm_decrypt()
