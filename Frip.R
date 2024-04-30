##### ================= usage manual ================= #####
# Rscript Frip.R input.bedGraph out.res.tmp
# arguments:
#	1st: the input bedGraph file. The 4th column is signal value
#	2nd: the output result file. The 1st line is FRiP, and 2nd line is SNR


### get parameters
if (T) {
	args = commandArgs(trailingOnly=TRUE)

	input_file = args[1]
	output_name = args[2]
}

### define the function of FRiP and SNR
if (T) {
	get_frip = function(x){
		x = x[x>0]
		z = (x-mean(x))/sd(x)
		z_p = pnorm(-(z))
		z_fdr_p = p.adjust(z_p, 'fdr')
		pk_sig = x[z_fdr_p<0.05]
		frip = sum(pk_sig) / sum(x)
		return(frip)
	}

	get_snr = function(x){
		x = x[x>0]
		z = (x-mean(x))/sd(x)
		z_p = pnorm(-(z))
		z_fdr_p = p.adjust(z_p, 'fdr')
		pk_sig = x[z_fdr_p<0.05]
		bg_sig = x[z_fdr_p>=0.05]
		snr = mean(pk_sig) / mean(bg_sig)
		return(snr)
	}
}

### read file list
if (T) {
	sig = read.table(input_file, header=F)[,4]
}

### get frip and snr
if (T) {
	frip=get_frip(sig)
	snr=get_snr(sig)
	results=c(frip,snr)
	print(paste0(basename(input_file),": [FRiP:",frip,"];"," [SNR:",snr,"]"))
}


### write output
if (T) {
	write.table(results, output_name, quote=F, sep='\t', col.names=F, row.names=F)
}
