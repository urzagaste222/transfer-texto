
### setup.py
```python
#!/usr/bin/env python3
"""
Setup para Transfer Texto
"""

from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="transfer-texto",
    version="1.0.0",
    author="Tu Nombre",
    author_email="tu@email.com",
    description="Transferencia de texto entre Linux Mint y Termux",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/TU_USUARIO/transfer-texto",
    packages=find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: POSIX :: Linux",
        "Operating System :: Android",
    ],
    python_requires=">=3.6",
    entry_points={
        "console_scripts": [
            "transfer-server=src.servidor:main",
            "transfer-client=src.cliente:main",
        ],
    },
)
