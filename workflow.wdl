version 1.0

workflow split_VCFs {

    meta {
        author: "Phuwanat Sakornsakolpat"
        email: "phuwanat.sak@mahidol.edu"
        description: "Split"
    }

     input {
        File vcf
        File tabix
    }

    scatter(num in [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,"X"]) {
		call run_splitting { 
			input: vcf = vcf, tabix = tabix, num = num
		}
	}

    output {
        Array[File] splitted_vcf = run_splitting.out_file
    }

}

task run_splitting {
    input {
        File vcf
        File tabix
        Int memSizeGB = 8
        Int threadCount = 2
        String num
        Int diskSizeGB = 5*round(size(vcf, "GB")) + 20
	String out_name = basename(vcf, ".vcf.gz")
    }
    
    command <<<
	bcftools view -r chr~{num} -Oz -o ~{out_name}.chr~{num}.vcf.gz ~{vcf}
    >>>

    output {
        File out_file = select_first(glob("*.chr~{num}.vcf.gz"))
    }

    runtime {
        memory: memSizeGB + " GB"
        cpu: threadCount
        disks: "local-disk " + diskSizeGB + " SSD"
        docker: "quay.io/biocontainers/bcftools@sha256:f3a74a67de12dc22094e299fbb3bcd172eb81cc6d3e25f4b13762e8f9a9e80aa"   # digest: quay.io/biocontainers/bcftools:1.16--hfe4b78e_1
        preemptible: 2
    }

}
