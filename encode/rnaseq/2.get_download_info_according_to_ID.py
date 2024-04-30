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
		url = 'https://www.encodeproject.org/experiments/' + id + '/?format=json'
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
		File_name = []
		Download_url = []
		md5 = []
		Other_alias = []
		Sample_info = []
		Other_ID = []
		Run_mode = []
		Run_length = []
		Target = []
		Control = []
		Biological_replicate = []
		Technical_replicate = []
		Experiment_info = []
		Lab = []
	# 循环爬取信息
	if True:
		files = biosample['files']
		for file in files:
			file_type = file['file_format']
			if (file_type == "fastq"):
				# Experiment_ID
				Experiment_ID.append(id)
				# Accession_ID
				result = file['accession']
				Accession_ID.append(result)
				# Lab
				result = file['lab']['title']
				Lab.append(result)
				# Other_alias & Sample_info & Other_ID &  Experiment_info
				rep_id = "rep" + str(file['replicate']['biological_replicate_number']) + "_" + str(file['replicate']['technical_replicate_number'])
				replicates = biosample['replicates']
				for x in replicates:
					rep_id_ck = "rep" + str(x['biological_replicate_number']) + "_" + str(x['technical_replicate_number'])
					if rep_id_ck == rep_id:
						if x['status'] == "archived" or x['status'] == "released":
							# Sample_info
							if ("simple_summary" in x['library']["biosample"].keys() or "summary" in x['library']["biosample"].keys() or "description" in x['library']["biosample"].keys()):
								result = ""
								if "simple_summary" in x['library']["biosample"].keys() and len(x['library']["biosample"]["simple_summary"])>0:
									result = x['library']["biosample"]["simple_summary"]
								if "summary" in x['library']["biosample"].keys() and len(x['library']["biosample"]["summary"])>0:
									if len(result) == 0:
										result = x['library']["biosample"]["summary"]
									else:
										result = result + ";" + x['library']["biosample"]["summary"]
								if "description" in x['library']["biosample"].keys() and len(x['library']["biosample"]["description"])>0:
									if len(result) == 0:
										result = x['library']["biosample"]["description"]
									else:
										result = result + ";" + x['library']["biosample"]["description"]
								result = result.replace(", ", ";")
								result = result.replace(" ", "_")
								Sample_info.append(result)
							else:
								Sample_info.append("NA")
							# Other_alias
							if ("aliases" in x['library']["biosample"].keys()):
								result = ";".join(x['library']["biosample"]["aliases"])
								result = result.replace(", ", ";")
								result = result.replace(" ", "_")
								Other_alias.append(result)
							else:
								Other_alias.append("NA")
							# Other_ID
							if ("dbxrefs" in x['library'].keys()):
								result = ";".join(x['library']["dbxrefs"])
								result = result.replace(", ", ";")
								result = result.replace(" ", "_")
								if len(result) == 0:
									Other_ID.append("NA")
								else:
									Other_ID.append(result)
							else:
								Other_ID.append("NA")
							# Experiment_info
							if ("extraction_method" in x['library'].keys() or "fragmentation_methods" in x['library'].keys() or "library_size_selection_method" in x['library'].keys() or "size_range" in x['library'].keys() or "treatments" in x['library'].keys()):
								result = ""
								if "extraction_method" in x['library'].keys() and len(x['library']["extraction_method"])>0:
									result = x['library']["extraction_method"]
								if "fragmentation_methods" in x['library'].keys() and len(x['library']["fragmentation_methods"])>0:
									if len(result) == 0:
										result = x['library']["fragmentation_methods"]
										result = ";".join(result)
									else:
										result = result + ";" + ";".join(x['library']["fragmentation_methods"])
								if "library_size_selection_method" in x['library'].keys() and len(x['library']["library_size_selection_method"])>0:
									if len(result) == 0:
										result = x['library']["library_size_selection_method"]
									else:
										result = result + ";" + x['library']["library_size_selection_method"]
								if "size_range" in x['library'].keys() and len(x['library']["size_range"])>0:
									if len(result) == 0:
										result = x['library']["size_range"]
									else:
										result = result + ";" + x['library']["size_range"]
								if "treatments" in x['library'].keys() and len(x['library']["treatments"])>0:
									if len(result) == 0:
										result = x['library']["treatments"]
										result = ";".join(result)
									else:
										result = result + ";" + ";".join(x['library']["treatments"])
								result = result.replace(", ", ";")
								result = result.replace(" ", "_")
								Experiment_info.append(result)
							else:
								Experiment_info.append("NA")
				# Download_url:
				result = 'https://www.encodeproject.org' + file['href']
				Download_url.append(result)
				# md5
				result = file['md5sum']
				md5.append(result)
				# Run_mode
				result = file['run_type']
				Run_mode.append(result)
				# Run_length
				result = str(file['read_length'])
				Run_length.append(result)
				# Target
				target_protein = biosample['assay_title'].replace(" ", "_")
				Target.append(target_protein)
				# Control
				result = file['replicate']['experiment']['possible_controls']
				result = [x.split("/")[2] for x in result]
				result = ";".join(result)
				if len(result) == 0:
					result = "NA"
				Control.append(result)
				# Biological_replicate
				result = [str(x) for x in file["biological_replicates"]]
				result = ";".join(result)
				Biological_replicate.append(result)
				# Technical_replicate
				result = ";".join(file["technical_replicates"])
				Technical_replicate.append(result)
				# File_name
				run_mode = file['run_type']
				fid = file['accession']
				rep = str(file["technical_replicates"][0])
				if (run_mode == "paired-ended"):
					read = file["paired_end"]
					paired_file = file["paired_with"].split("/")[2]
					if (read == "1"):
						result = fid + "+" + paired_file + "_" + target_protein + "_rep" + rep + "_R1.fq.gz"
					else:
						result = paired_file + "+" + fid + "_" + target_protein + "_rep" + rep + "_R2.fq.gz"
				else:
					result = fid + "_" + target_protein + "_rep" + rep + "_RR.fq.gz"
				File_name.append(result)
	# 结果汇总整理
	if True:
		results = {}
		results['Experiment_ID'] = Experiment_ID
		results['Accession_ID'] = Accession_ID
		results['File_name'] = File_name
		results['Download_url'] = Download_url
		results['md5'] = md5
		results['Other_alias'] = Other_alias
		results['Sample_info'] = Sample_info
		results['Other_ID'] = Other_ID
		results['Run_mode'] = Run_mode
		results['Run_length'] = Run_length
		results['Target'] = Target
		results['Control'] = Control
		results['Biological_replicate'] = Biological_replicate
		results['Technical_replicate'] = Technical_replicate
		results['Experiment_info'] = Experiment_info
		results['Lab'] = Lab
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

