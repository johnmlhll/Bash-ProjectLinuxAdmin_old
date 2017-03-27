#!/bin/bash

#Script Definition: Create a student marks processing script with output folders
#showing student results by student id.

if [[ ! -d "output" ]];then
	echo "***Progress Note: output directory does not exist"
	echo "***************" 
	mkdir ./output/ 2>/dev/null
	echo "Note: output directory created"
else
	echo "***Progress Note: using existing directory: output"
	echo "**************"
fi
#loop global vars
declare -a ARRAY
declare MODULENAME
declare GRADE
declare REPEAT

#creating the StudentID directory and reading in the Details.txt file 
while read -r LINE;do
	#Validation of adddress lines using regex
	rm "$1/validated_student_details.txt" 2>/dev/null
	touch "$1/validated_student_details.txt"
	sed -E 's/(.*[0-9]{2}\/[0-9]{2}\/[0-9]{4} )([^"])(.*)([^"])$/\1"\2\3\4"/' <<< $LINE >> "$1/validated_student_details.txt"
	echo "" #New student line of progress updates/processing
	echo "***Progress Note: New Student Line: Detail successfully transformed"
	while read -r LINE2; do
		echo "Transformed line: $LINE2"
		declare -a "ARRAY=( $LINE2 )" #get rid of double quotes with "" in redeclare
		if [[ ! -d 'output/${ARRAY[0]}/' ]];then
			mkdir -p "output/${ARRAY[0]}/" 2>/dev/null
			echo "***Progress note: Student ${ARRAY[0]}: Directory created"
			echo "*****************"
		else
			echo "***Progress note: Student ${ARRAY[0]}: Directory already created"
			echo "*****************"
		fi        
		if [[ ! -f "output/${ARRAY[0]}/Details.txt" ]];then
			touch "output/${ARRAY[0]}/Details.txt" 2>/dev/null
			echo "***Progress note: Details file created for Student Number ${ARRAY[0]}"
			echo "*****************"
		else
			rm "output/${ARRAY[0]}/Details.txt" 2>/dev/null
		fi
		echo -e "\n*********************" "\n***Student Details***" "\n*********************" "\nEntered Time: $(date +%T)" 		"\nEntered Date: $(date +%F)" "\n*********************" "\nSurname: ${ARRAY[1]}" "\nName: ${ARRAY[2]}" "\nDate of Birth: 	 ${ARRAY[3]}" "\nAddress: ${ARRAY[4]}">>"output/${ARRAY[0]}/Details.txt"
		echo "***Progress Note: Student details (entry time/date) successfully written to the student's 'Details.txt' file"
		rm "output/${ARRAY[0]}/Notes.txt" #delete notes.txt prior to assigning new multi block results
		#read by line the subdirectories in input and create $SUBDIR.txt files in output/studentId directories
		DIR=$1	#argument passed should be "input"folder
		for SUBDIR in $( ls $DIR );do
			if [[ ! -d "$DIR/$SUBDIR" ]];then
				echo "***Progress Note: $DIR/$SUBDIR not a directory"
				echo "****************"
			else
				if [[ -f "output/${ARRAY[0]}/$SUBDIR.txt" ]]; then
					rm "output/${ARRAY[0]}/$SUBDIR.txt"
					touch "output/${ARRAY[0]}/$SUBDIR.txt" 2>/dev/null
			 		echo "***Progress Note: Subdirectory $DIR/$SUBDIR found and used to create: output/${ARRAY[0]}/$SUBDIR.txt"
					echo "****************"
				fi
				if [[ ! -f "output/${ARRAY[0]}/Notes.txt" ]];then
					touch "output/${ARRAY[0]}/Notes.txt" 2>/dev/null
					echo "***Progress Note: Subdirectory $DIR/$SUBDIR found and used to create: output/${ARRAY[0]}/Notes.txt"
					echo "****************"
				fi
				#Data Validation Assignement subroutine concerning student blocks and notes.txt
				declare -a RESULT
				for MODULE in $( ls "$DIR/$SUBDIR" );do #Assigns TO Studentblocks
				MODULENAME=${MODULE%.*}
					if [[ -f "$DIR/$SUBDIR/$MODULE" ]];then
						while read MODULE;do
							declare -a "RESULT=( $MODULE )"
							GRADE=${RESULT[1]}
							if [[ "${RESULT[0]}" == "${ARRAY[0]}" ]];then				
								sort | uniq -u | echo -e  "$MODULENAME ${RESULT[1]}">>"output/${ARRAY[0]}/$SUBDIR.txt"
								if [[ "${RESULT[1]}" < 40 ]];then
								sort | uniq -u | echo -e "Failed: $MODULENAME $GRADE">>"output/${ARRAY[0]}/Notes.txt"
								REPEAT=$MODULENAME
								fi
								if [[ $MODULENAME == $REPEAT ]];then
								if [[ "${RESULT[1]}" > 39 ]];then
								sort | uniq -u | echo -e "Passed: $MODULENAME ${RESULT[1]}">>"output/${ARRAY[0]}/Notes.txt";
								REPEAT=""
								fi;
								fi; 
							fi
						done < "$DIR/$SUBDIR/$MODULE"
						echo "***Progress Note: Student ${ARRAY[0]} block.txt files successfully updated"
					fi
				done
			fi
		done
	done < "$1/validated_student_details.txt"
done < "$1/Students.txt"

echo "***Progress Note: process completed. Output files available in output folder"
echo "****************************************************************************"
#End of actual project script
