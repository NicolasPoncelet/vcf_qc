# Variables 

QUAL = [20,30,40]
MINDP = [2,3,4,5]
MAXDP = [5,6,8]
MAF = [0.05,0.10]
MISS = [1.0,0.9]

rule target:
    input:
        expand(
            'Metrics/Q{qual}_mindp{mindp}_max_dp{maxdp}_maf{maf}_miss{miss}.vcf.gz',
            qual = QUAL,
            mindp = MINDP,
            maxdp = MAXDP,
            maf = MAF,
            miss = MISS,
        ),

rule filtering_vcf:
	input: 
		vcf = "fraction_Po_IR.vcf.gz",
	output: 
		filtered_vcf ='Filtered_vcf/Q{qual}_mindp{mindp}_max_dp{maxdp}_maf{maf}_miss{miss}.vcf.gz',
	params:
		qual = QUAL,
		mindp = MINDP,
		maxdp = MAXDP,
		maf = MAF,
		miss = MISS,
	shell:
		"""
		vcftools --gzvcf {input.vcf} \
		--minDP {params.mindp} --maxDP {params.maxdp} --minQ {params.qual} --remove-indels \
		--recode --recode-INFO-all --maf {params.maf} \
		--max-missing {params.miss} --stdout | gzip -c > {output.filtered_vcf}
		"""

rule get_metrics:
	input:
		vcf_to_qc = 'Filtered_vcf/Q{qual}_mindp{mindp}_max_dp{maxdp}_maf{maf}_miss{miss}.vcf.gz',
	output:
		vcf_metrics = 'Metrics/Q{qual}_mindp{mindp}_max_dp{maxdp}_maf{maf}_miss{miss}',
	shell:
		"""
		vcftools --gzvcf {input.vcf_to_qc} --freq2 --max-alleles 2 --out {output.vcf_metrics} 
		vcftools --gzvcf {input.vcf_to_qc} --depth --out {output.vcf_metrics}
		vcftools --gzvcf {input.vcf_to_qc} --site-mean-depth --out {output.vcf_metrics}
		vcftools --gzvcf {input.vcf_to_qc} --site-quality --out {output.vcf_metrics}
		vcftools --gzvcf {input.vcf_to_qc} --missing-indv --out {output.vcf_metrics}
		vcftools --gzvcf {input.vcf_to_qc} --missing-site --out {output.vcf_metrics}
		"""