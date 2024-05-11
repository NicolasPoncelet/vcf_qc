
rule all:
    input:
        expand(
            'Output_file/out_Q{qual}_mindp{mindp}_max_dp{maxdp}_maf{maf}_miss{miss}.vcf.gz',
            qual = [20,30,40],
            mindp = [2,3,4,5],
            maxdp = [5,6,8],
            maf = [0.05,0.10],
            miss = [1.0,0.9],
        ),

rule filtering_vcf:
	input: 
		"Test_data/fraction_Po_IR.vcf.gz",
	output: 
		'Output_file/out_Q{qual}_mindp{mindp}_max_dp{maxdp}_maf{maf}_miss{miss}.vcf.gz',
	shell:
		"""
		vcftools --gzvcf {input} \
		--minDP {{wildcard.mindp}} --maxDP {{wildcard.maxdp}} --minQ {{wildcard.qual}} --remove-indels \
		--recode --recode-INFO-all --maf {{wildcard.maf}} \
		--max-missing {{wildcard.miss}} --stdout | gzip -c > {output}
		"""
