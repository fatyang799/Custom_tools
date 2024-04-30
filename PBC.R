##### ================= usage manual ================= #####
# Rscript PBC.R input.bam out.res.tmp
# arguments:
#   1st: the input bam file.
#   2nd: the output result file. The 1st line is PBC1, and 2nd line is PBC2


### get parameters
if (T) {
    args = commandArgs(trailingOnly=TRUE)

    input_file = args[1]
    output_name = args[2]
}

### define the function of PBC1 and PBC2
if (T) {
    PBC <- function(IP) {

        # load ChIP sample if necessary
        if (is.character(IP)) {
            if (!file.exists(IP))
                stop(paste("File", IP, "does NOT exist."))
            else
                aln <- GenomicAlignments::readGAlignments(IP)
        } else if (class(IP) == "GAlignments") {
            aln <- IP
        } else {
            stop("IP must be a file path or a GAlignments object.")
        }

        # convert GAlignments object to data.table for fast aggregation
        aln <- data.table::data.table(
            strand=as.factor(BiocGenerics::as.vector(GenomicAlignments::strand(aln))),
            seqnames=as.factor(BiocGenerics::as.vector(GenomicAlignments::seqnames(aln))),
            pos=ifelse(GenomicAlignments::strand(aln) == "+", start(aln), end(aln))
        )

        # aggregate reads by position and count them
        readsPerPosition <- aln[,list(count=.N), by=list(strand, seqnames, pos)]$count

        # PBC = positions with exactly 1 read / positions with at least 1 read
        PBC1 <- sum(readsPerPosition == 1) / length(readsPerPosition)
        PBC2 <- sum(readsPerPosition == 1) / sum(readsPerPosition == 2)
        PBC <- c(PBC1,PBC2)

        return(PBC)
    }
}

### get PBC value result and output the result
if (T) {
    results=PBC(input_file)
    print(paste0(basename(input_file),": [PBC1:",results[1],"];"," [PBC2:",results[2],"]"))
}

### write output
if (T) {
    write.table(results, output_name, quote=F, sep='\t', col.names=F, row.names=F)
}
