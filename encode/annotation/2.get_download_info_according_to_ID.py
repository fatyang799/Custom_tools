# 导入模块
if True:
	import json
	import re
	import requests
	import pandas as pd

# 定义文件
if True:
	# 上一步拿到的实验ID
	input = "results/1.ID.txt"
	# output file name
	output = "results/2.Experiment_ID_info.csv"

# 读入ID
if True:
	with open(input,"r") as f:
		ids = f.readlines()
	# 去除换行符
	ids = [id.strip() for id in ids]

# 根据ID读取信息
def get_Experiment_info_from_ENCODE(id):
	print("\tBegining to fetch Experiment data of " + id + " from ENCODE!")
	# 连接网络拿到json全部信息
	if True:
		headers = {
			'User-Agent': 'Mozilla/5.0 (Windows NT 10.0;WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36',
			'accept': 'application/json'
		}
		url = 'https://www.encodeproject.org/annotations/' + id + '/?format=json'
		try:
			# 设置必须在60s

			# 内收到响应，不然或抛出ReadTimeout异常
			response = requests.get(url, headers=headers, timeout=60)
			biosample = response.json()
			# print(response.status_code)
		except Exception:
			print('Timeout')
	# 设置需要拿到的信息
	if True:
		Experiment_ID = []
		Accession_ID = []
		Lab = []
		Download_url = []
		md5 = []
		Assembly = []
		Version = []
		Description = []
	# 循环爬取信息
	if True:
		files = biosample['files']
		for file in files:
			file_type = file['file_format']
			if (file_type == "bed"):
				# Experiment_ID
				Experiment_ID.append(id)
				# Accession_ID
				result = file['accession']
				Accession_ID.append(result)
				# Lab
				result = file['lab']['title']
				result = result.replace(", ", ";")
				result = result.replace(" ", "_")
				Lab.append(result)
				# Download_url:
				result = 'https://www.encodeproject.org' + file['href']
				Download_url.append(result)
				# md5
				result = file['md5sum']
				md5.append(result)
				# Assembly
				result = file['assembly']
				Assembly.append(result)
				# Version
				result = ";".join(file['encyclopedia_version'])
				Version.append(result)
				# Description
				result = biosample['description']
				result = result.replace(", ", ";")
				result = result.replace(" ", "_")
				Description.append(result)
	# 结果汇总整理
	if True:
		results = {}
		results['Experiment_ID'] = Experiment_ID
		results['Accession_ID'] = Accession_ID
		results['Lab'] = Lab
		results['Download_url'] = Download_url
		results['md5'] = md5
		results['Assembly'] = Assembly
		results['Version'] = Version
		results['Description'] = Description
	# 返回结果
	return (results)

# 批量爬取ID信息并整理为dataframe
if True:
	data = get_Experiment_info_from_ENCODE(ids[0])
	data = pd.DataFrame(data)
	# 合并所有数据
	for i in range(1,len(ids)):
		id = ids[i]
		id = get_Experiment_info_from_ENCODE(id)
		id = pd.DataFrame(id)
		data = pd.concat([data, id], axis=0)

# 信息导出
if True:
	data.to_csv(output, index=False)


