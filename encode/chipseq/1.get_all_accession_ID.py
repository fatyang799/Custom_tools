# 导入模块
if True:
	import re
	import os
	import urllib.request
	import sys

# 输入你搜索后的网页，举例：https://www.encodeproject.org/search/?type=Experiment&control_type%21=%2A&assay_title=Histone+ChIP-seq
url = str(sys.argv[1])

# 输出文件名
if True:
	output = "results/1.ID.txt"
	a = os.system("mkdir -p results")

# 读取网页全部信息
if True:
	# 读入原始网页数据
	content = urllib.request.urlopen(url)
	# 解码
	readable_content = content.read().decode("utf-8")

# 使用正则表达式提取信息
if True:
	pat = '<div class="result-item__meta-id"> (ENCSR.{6})</div>'
	ID = re.compile(pat).findall(readable_content)

# 信息导出
if True:
	with open(output,"w") as f:
		f.write("\n".join(ID))
