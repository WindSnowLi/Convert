"""
Media Converter - 多媒体格式转换工具

一个美观实用的音视频图片格式转换网页工具，支持网易云音乐 NCM 格式解密。
"""

from setuptools import setup, find_packages
import os

# 读取 README
def read_file(filename):
    with open(filename, encoding='utf-8') as f:
        return f.read()

# 读取版本号
def get_version():
    version_file = os.path.join('src', 'media_converter', '__init__.py')
    with open(version_file, encoding='utf-8') as f:
        for line in f:
            if line.startswith('__version__'):
                return line.split('=')[1].strip().strip('"').strip("'")
    return '1.0.0'

setup(
    name='media-converter',
    version=get_version(),
    author='Your Name',
    author_email='your.email@example.com',
    description='多媒体格式转换工具 - 支持音频、视频、图片及 NCM 格式',
    long_description=read_file('README.md'),
    long_description_content_type='text/markdown',
    url='https://github.com/yourusername/media-converter',
    project_urls={
        'Bug Reports': 'https://github.com/yourusername/media-converter/issues',
        'Source': 'https://github.com/yourusername/media-converter',
        'Documentation': 'https://github.com/yourusername/media-converter/blob/main/docs/README.md',
    },
    
    # 包配置
    package_dir={'': 'src'},
    packages=find_packages(where='src'),
    include_package_data=True,
    
    # Python 版本要求
    python_requires='>=3.7',
    
    # 依赖包
    install_requires=[
        'Flask>=3.0.0',
        'Pillow>=10.1.0',
        'Werkzeug>=3.0.1',
        'pycryptodome>=3.19.0',
        'pyncm',
    ],
    
    # 开发依赖
    extras_require={
        'dev': [
            'pytest>=7.0.0',
            'pytest-cov>=4.0.0',
            'black>=23.0.0',
            'flake8>=6.0.0',
            'mypy>=1.0.0',
            'isort>=5.12.0',
        ],
        'docs': [
            'sphinx>=6.0.0',
            'sphinx-rtd-theme>=1.2.0',
        ],
    },
    
    # 包数据
    package_data={
        'media_converter': [
            'templates/*.html',
            'static/*',
        ],
    },
    
    # 入口点
    entry_points={
        'console_scripts': [
            'media-converter=media_converter.app:main',
        ],
    },
    
    # 分类器
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: End Users/Desktop',
        'Topic :: Multimedia :: Sound/Audio :: Conversion',
        'Topic :: Multimedia :: Video :: Conversion',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3.10',
        'Programming Language :: Python :: 3.11',
        'Programming Language :: Python :: 3.12',
        'Operating System :: OS Independent',
        'Environment :: Web Environment',
        'Framework :: Flask',
    ],
    
    # 关键词
    keywords='media converter audio video image ncm netease-cloud-music format-conversion',
    
    # 许可证
    license='MIT',
    
    # Zip 安全
    zip_safe=False,
)
