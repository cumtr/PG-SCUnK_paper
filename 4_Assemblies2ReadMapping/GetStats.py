
# This script is the second version (v2)

import json
import argparse
import sys

def count_aligned_reads_and_secondary_scores(file):
    reads = 0
    aligned_reads = 0
    number_secondary = 0
    perfect_alignment_reads = 0
    perfect_alignment_number_secondary = 0
    score_160_reads = 0
    non_null_score_reads = 0
    quality_60_or_higher = 0
    quality_30_or_higher = 0
    secondary_score_160 = 0
    secondary_as_good_as_primary = 0

    for line in file:
        reads += 1
        data = json.loads(line)
        
        score = int(data.get('score', 0))
        quality = int(data.get('mapping_quality', 0))
        secondary_scores = data.get('annotation', {}).get('secondary_scores', [])
        
        if score:
            aligned_reads += 1
        
        if score == 160:
            score_160_reads += 1
        
        if score > 0:
            non_null_score_reads += 1
        
        if quality >= 60:
            quality_60_or_higher += 1
        
        if quality >= 30:
            quality_30_or_higher += 1
        
        if len(secondary_scores) > 1 and secondary_scores[1] == 160:
            secondary_score_160 += 1
        
        if len(secondary_scores) > 1 and secondary_scores[1] == score:
            secondary_as_good_as_primary += 1
        
        is_perfect = (score == 160)
        if is_perfect:
            perfect_alignment_reads += 1
        
        if len(secondary_scores) > 1 and secondary_scores[1] == secondary_scores[0]:
            number_secondary += 1
            if is_perfect:
                perfect_alignment_number_secondary += 1
    
    return (reads, aligned_reads, perfect_alignment_reads, number_secondary, 
            perfect_alignment_number_secondary, score_160_reads, non_null_score_reads, 
            quality_60_or_higher, quality_30_or_higher, secondary_score_160, secondary_as_good_as_primary)

def main():
    parser = argparse.ArgumentParser(description='Count aligned reads and secondary scores in JSON lines.')
    parser.add_argument('-f', '--file', help='Input file containing JSON lines')
    args = parser.parse_args()

    if args.file:
        with open(args.file, 'r') as file:
            results = count_aligned_reads_and_secondary_scores(file)
    else:
        results = count_aligned_reads_and_secondary_scores(sys.stdin)

    (reads, aligned_reads, perfect_alignment_reads, number_secondary, 
     perfect_alignment_number_secondary, score_160_reads, non_null_score_reads, 
     quality_60_or_higher, quality_30_or_higher, secondary_score_160, secondary_as_good_as_primary) = results

    print("#file\treads\taligned_reads\tperfect_alignment_reads\tnumber_secondary\t" 
          "perfect_alignment_number_secondary\tscore_160_reads\tnon_null_score_reads\t" 
          "quality_60_or_higher\tquality_30_or_higher\tsecondary_score_160\tsecondary_as_good_as_primary")
    print(f"{args.file if args.file else 'stdin'}\t{reads}\t{aligned_reads}\t{perfect_alignment_reads}\t" 
          f"{number_secondary}\t{perfect_alignment_number_secondary}\t{score_160_reads}\t" 
          f"{non_null_score_reads}\t{quality_60_or_higher}\t{quality_30_or_higher}\t" 
          f"{secondary_score_160}\t{secondary_as_good_as_primary}")

if __name__ == "__main__":
    main()
