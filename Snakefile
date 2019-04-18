import pandas as pd



cfg = {
	"perms": 10000,
	"genome": "resources/genome.hg19",
	"awk_script": "code/sum.awk",
	"indexpath": "resources/uniq.cases.txt"
}

sample_names = pd.read_table(cfg["indexpath"], header=None, names=["SampleName"])


rule process_all:
	input: expand("plots/{case_id}_plot.pdf", case_id=sample_names["SampleName"])
	

rule generate_plot:
	input:
		"output/{case_id}_true_overlap.txt",
		"output/{case_id}_null_dist.txt"
	output:
		"plots/{case_id}_plot.pdf"
	script:
		"code/plot.R"


rule process_single_case:
	input:
		"scratch/{case_id}_clonal.bed",
		"scratch/{case_id}_subclonal.bed",
	output:
		"output/{case_id}_true_overlap.txt",
		"output/{case_id}_null_dist.txt",
	params:
		perms = cfg["perms"],
		genome_file = cfg["genome"],
		awk_src = cfg["awk_script"],
	shell:
		"""
		for i in $(seq 1 {params.perms})
		do
		bedtools shuffle -i {input[1]} -g {params.genome_file} \
			| bedtools intersect -a - -b {input[0]} -wo \
			| awk -f {params.awk_src} - >> {output[1]}
		done;
		bedtools intersect -a {input[1]} -b {input[0]} -wo | awk -f {params.awk_src} - >> {output[0]}
		"""
