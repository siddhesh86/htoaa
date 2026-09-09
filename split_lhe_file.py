import os

#input_file = "/eos/cms/store/group/phys_susy/HToaaTo4b/LHE/SM_HTo4b_LO_13p6/2026_09_01/pp-ggH-4b-single.lhe"  
#output_dir = "/eos/cms/store/group/phys_susy/HToaaTo4b/LHE/SM_HTo4b_LO_13p6/2026_09_01/vSplit/pp-ggH-4b"
input_file = "/eos/cms/store/group/phys_susy/HToaaTo4b/LHE/SM_HTo4b_LO_13p6/2026_09_01/pp-WH-W4b-single.lhe"  
output_dir = "/eos/cms/store/group/phys_susy/HToaaTo4b/LHE/SM_HTo4b_LO_13p6/2026_09_01/vSplit/pp-WH-W4b"

events_per_file = 1000

print(f"{input_file = }, \n{output_dir}, \n{events_per_file = }\n")

header = []
footer = "</LesHouchesEvents>\n"
events = []

# Read and parse the file
with open(input_file, "r") as f:
  in_event = False
  current_event = []

  for line in f:
    if "<event>" in line:
      in_event = True
      current_event = [line]
    elif "</event>" in line:
      current_event.append(line)
      events.append("".join(current_event))
      in_event = False
      current_event = []
    elif in_event:
      current_event.append(line)
    else:
      # Everything before the first event goes into the header (includes <init>)
      if not events and "</LesHouchesEvents>" not in line:
        header.append(line)

# Write out the split files
total_events = len(events)
file_index = 0
inputFileBaseName = os.path.basename(input_file)
inputFileBaseName_woExtension = inputFileBaseName.replace('.lhe', '')
for i in range(0, total_events, events_per_file):
  chunk = events[i : i + events_per_file]
  output_name = f"{output_dir}/{inputFileBaseName_woExtension}_{file_index}.lhe"

  with open(output_name, "w") as out_f:
    out_f.writelines(header)
    out_f.writelines(chunk)
    out_f.write(footer)

  print(f"Wrote {len(chunk)} events to {output_name}")
  file_index += 1
