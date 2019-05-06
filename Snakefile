import pandas as pd

cfg = {
	"perms": 10000,
	"genome": "resources/genome.hg19",
	"sorted_genome": "resources/sorted.genome.hg19",
	"awk_script": "code/sum.awk",
	"indexpath": "resources/uniq.cases.txt"
}

sample_names = pd.read_table(cfg["indexpath"], header=None, names=["SampleName"])


rule process_all:
	input: expand("plots/{case_id}_plot.pdf", case_id=sample_names["SampleName"])


rule fisher:
	input: expand("fisher/{case_id}.txt", case_id=sample_names["SampleName"])


rule fisher_single_case:
	input:
		"sorted/{case_id}_clonal.bed",
		"sorted/{case_id}_subclonal.bed"
	output:
		"fisher/{case_id}.txt"
	params:
		genome_file = cfg["sorted_genome"],
	shell:
		"""
		bedtools fisher -a {input[0]} -b {input[1]} -g {params.genome_file} > {output}
		"""
	
rule sort_all:
	input:
		expand("sorted/{case_id}_{muttype}.bed",
			case_id = sample_names["SampleName"],
			muttype = ["clonal", "subclonal"])

rule sort_sample:
	input:
		"scratch/{case_id}_clonal.bed",
		"scratch/{case_id}_subclonal.bed",
	output:
		"sorted/{case_id}_clonal.bed",
		"sorted/{case_id}_subclonal.bed"
	shell:
		"""
		sort -k 1,1 -k2,2n {input[0]} > {output[0]}  &&
		sort -k 1,1 -k2,2n {input[1]} > {output[1]}
		"""

rule generate_raw_beds:
	input:
		"data/Suppl_Table_2_Clones.xlsx"
	output:
		expand("per_type/{case_id}_{segment_state}_{muttype}.bed",
			case_id=sample_names["SampleName"],
			segment_state=["loss", "gain"],
			muttype=["clonal", "subclonal"])
	script:
		"code/generate_beds.R"

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
		"sorted/{case_id}_clonal.bed",
		"sorted/{case_id}_subclonal.bed",
	output:
		"output/{case_id}_true_overlap.txt",
		"output/{case_id}_null_dist.txt",
	params:
		perms = cfg["perms"],
		genome_file = cfg["sorted_genome"],
		awk_src = cfg["awk_script"],
	shell:
		"""
		for i in $(seq 1 {params.perms})
		do
		bedtools shuffle -i {input[1]} -g {params.genome_file} -maxTries 1000000 \
			| bedtools intersect -a - -b {input[0]} -wo \
			| awk -f {params.awk_src} - >> {output[1]}
		done;
		bedtools intersect -a {input[1]} -b {input[0]} -wo | awk -f {params.awk_src} - >> {output[0]}
		"""
