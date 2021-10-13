#Our goal is to identify the ideal pH-resistent methanogenic Archaea for use in growth experiments
#criteria 1: presence of McrA gene (methanogenesis)
#criteria 2: most copies of HSP70 gene (pH resistance)

#step 1: combine reference sequences
cat ref_sequences/mcrAgene_*.fasta > ref_sequences/mcrAgene.fasta
cat ref_sequences/hsp70gene_*.fasta > ref_sequences/hsp70gene.fasta

#step 2: make directory for results files
mkdir results

#step 3: align reference sequences
./muscle3.8.31_i86linux64 -in ref_sequences/mcrAgene.fasta -out results/mcrAgene_aligned.fasta
./muscle3.8.31_i86linux64 -in ref_sequences/hsp70gene.fasta -out results/hsp70gene_aligned.fasta

#step 4: build a profile hmm for each gene
./hmmbuild results/mcrAgene_profile.fasta results/mcrAgene_aligned.fasta
./hmmbuild results/hsp70gene_profile.fasta results/hsp70gene_aligned.fasta

#step 5: search each proteome for McrA gene
num=1
for proteome in proteomes/proteome_*.fasta
do
./hmmsearch --tblout results/proteome_"$num"_mcrA.fasta results/mcrAgene_profile.fasta $proteome
num=$(($num+1))
done

#step 6: search each proteome for HSP70 gene
num=1
for proteome in proteomes/proteome_*.fasta
do
./hmmsearch --tblout results/proteome_"$num"_hsp70.fasta results/hsp70gene_profile.fasta $proteome
num=$(($num+1))
done

#step 7: get number of matches for mcrA and HSP70 for each proteome
echo "Proteome,mcrA,HSP70" > Matches.txt
for num in {1..50}
do
mcrA=$(cat results/proteome_"$num"_mcrA.fasta | grep -w mcrAgene_aligned | wc -l)
hsp70=$(cat results/proteome_"$num"_hsp70.fasta | grep -w hsp70gene_aligned | wc -l)
echo "Proteome_$num,$mcrA,$hsp70" >> Matches.txt
done

#step 8: make file with recommendations
echo "Recommended-Proteome,mcrA,HSP70" > Recommendations.txt
cat Matches.txt | grep -v -w "0" | sort -t , -k 3n | tail -n 4 >> Recommendations.txt
