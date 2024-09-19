#!/bin/bash

# 23/04/2024
# Unix Programming - Assignment 4
# Elvin Jiby
#
# Bash script that prints the transcript for a B.Sc. in Computer Science
# using the source files: stage1.sh.inc, stage2.sh.inc, stage3.sh.inc,
# stage4.sh.inc, grades.sh.inc & mincredits.sh.inc
#
# Tested on Linux Mint 22 MATE
#
# Launch the script in the terminal as follows:
# ./assign4.sh <I|NI>
# where I represents you doing an internship in Stage 3
# and NI represents you NOT doing an internship in Stage 3
#
# The program starts with some argument handling, where if you have
# incorrect arguments or if you have --help as an argument, the program
# will print a message displaying how to use it like instructed here.
#
# Afterwards, the program uses the data from the source files, as well as
# the option you gave as an argument, to print out a transcript of a B.Sc.
# Computer Science degree. This includes information on the modules of each
# stage, the amount of credits they are worth, as well as a random assigned grade
# for each one. The total grade points earned will be displayed at the bottom.
# The program finishes after this.


# Include the source files
source ./stage1.sh.inc
source ./stage2.sh.inc
source ./stage3.sh.inc
source ./stage4.sh.inc
source ./grades.sh.inc
source ./mincredits.sh.inc

clear # clear the terminal beforehand
##########################################
# Script argument handling

# Usage message function
function print_usage() {
    echo "Correct usage: $0 <I|NI>
    I for internship in stage 3
    NI for no internship in stage 3
    "
    exit 1
}

# check for valid number of arguments
if [ "$#" -ne 1 ]; then
    print_usage
fi

# if --help is provided
if [ "$1" == "--help" ]; then
    print_usage
fi

# if argument is not "I" or "NI"
if [ "$1" != "I" ] && [ "$1" != "NI" ]; then
    print_usage
fi

##########################################
# Some variables
numGrades=${#grades[@]} # stores the number of grades that can be assigned to a module
totalGP=0 # variable to store the total grade points accumulated over the 4 stages

# Function to get a random index to select a grade
function getRandomGradeIndex() {
    local random_index=$(( RANDOM % "$numGrades" ))
    if (( random_index % 2 != 0 )); then # this ensures that the index doesn't point to a grade point
      (( random_index-- ))
    fi

    echo "$random_index" # return the random index
}

# Function that prints the transcript for a specific stage
function generate_stageInfo() {
    local stageNumber=$1 # contains the string for the stage number
    local minimumCredits=$2 # contains the minimum amount of credits for a given stage
    local coreModules=("${!3}") # contains the information of the core modules for a given stage
    local electives=("${!4}") # contains the information of the elective modules for a given stage
    local internshipOption=$5 # parameter that indicates if an internship was taken in stage 3 or not

    # Print stage number
    echo "$stageNumber" # print the stage number first

    # Print core modules
    coreModulesLength=$(( ${#coreModules[@]} / 3 )) # get the amount of core modules for that stage
    moduleIndex=0 # variable to store the index of the current modules array
    totalCredits=0 # variable to store the total amount of credits earned in a stage (used for checking for any electives required later)
    for (( i = 0; i < "$coreModulesLength"; i++ )); do
        random_gradeIndex=$(getRandomGradeIndex) # get random index for the grade

        grade="${grades[random_gradeIndex]}" # assign the grade
        gradePoint="${grades[random_gradeIndex+1]}" # assign the corresponding grade point
        totalGP=$(( totalGP + gradePoint )) # add the grade point to the total counter

        printf "%-9s " "${coreModules[moduleIndex]}" # print module code
        ((moduleIndex++)) # increment the index
        printf "%-50s " "${coreModules[moduleIndex]}" # print module name
        ((moduleIndex++)) # increment the index
        printf "%-4s " "${coreModules[moduleIndex]}" # print credits value
        totalCredits=$(( totalCredits + coreModules[moduleIndex] )) # add to the total amount of credits earned
        ((moduleIndex++)) # increment the index
        printf "%-5s " "$grade" # print grade
        printf "%-4s\n" "$gradePoint" # print grade point
    done

    # Print electives
    if [ "$stageNumber" == "Stage 3" ]; then # if in stage 3
        if [ "$internshipOption" == "I" ]; then
            # Internship TAKEN, so print internship module

            moduleIndex=0 # variable to store the current index of the modules array
            random_gradeIndex=$(getRandomGradeIndex) # get random index for the grade
            grade="${grades[random_gradeIndex]}" # assign the grade
            gradePoint="${grades[random_gradeIndex+1]}" # assign the corresponding grade point
            totalGP=$(( totalGP + gradePoint )) # add the grade point to the total counter

            printf "%-9s " "${electives[moduleIndex]}" # print module code
            ((moduleIndex++)) # increment the index
            printf "%-50s " "${electives[moduleIndex]}" # print module name
            ((moduleIndex++)) # increment the index
            printf "%-4s " "${electives[moduleIndex]}" # print credits value
            totalCredits=$(( totalCredits + electives[moduleIndex] )) # add to the total amount of credits earned
            printf "%-5s " "$grade" # print grade
            printf "%-4s\n" "$gradePoint" # print grade point
        else
            # NO Internship taken, print software engineering project module

            moduleIndex=3 # variable to store the current index of the modules array (starting from Software Eng. Project)
            random_gradeIndex=$(getRandomGradeIndex) # get random index for the grade
            grade="${grades[random_gradeIndex]}" # assign the grade
            gradePoint="${grades[random_gradeIndex+1]}" # assign the corresponding grade point
            totalGP=$(( totalGP + gradePoint )) # add the grade point to the total counter

            printf "%-9s " "${electives[moduleIndex]}" # print module code
            ((moduleIndex++)) # increment the index
            printf "%-50s " "${electives[moduleIndex]}" # print module name
            ((moduleIndex++)) # increment the index
            printf "%-4s " "${electives[moduleIndex]}" # print credits value
            totalCredits=$(( totalCredits + electives[moduleIndex] )) # add to the total amount of credits earned
            printf "%-5s " "$grade" # print grade
            printf "%-4s\n" "$gradePoint" # print grade point
        fi
    else
      # We know we're dealing with Stage 1,2,4 information at this point
      numElectives=$(( ${#electives[@]} / 3 )) # stores number of electives for that stage
      selectedElectivesList=() # array to store already selected electives

      if [ "$totalCredits" -lt "$minimumCredits" ]; then # check if electives are needed to fulfill the minimum credits for that stage
        local electivesNeeded=$(( (minimumCredits - totalCredits) / 5 )) # if so, calculate how many elective modules are needed
        random_electiveIndex=$(( (RANDOM % numElectives) * 3 )) # get a random index for an elective

        for (( i = 0; i < electivesNeeded; i++ )); do # iterate until the electives needed are chosen
          # Loop to prevent same elective being picked again
          while [[ ${selectedElectivesList[*]} =~ ${electives[random_electiveIndex]} ]]; do
              random_electiveIndex=$(( (RANDOM % numElectives) * 3 ))
          done
          selectedElectivesList+=("${electives[random_electiveIndex]}") # add the elective to the array so next time it doesn't get chosen again

          random_gradeIndex=$(getRandomGradeIndex) # get random index for the grade
          grade="${grades[random_gradeIndex]}" # assign the grade
          gradePoint="${grades[random_gradeIndex+1]}" # assign the corresponding grade point
          totalGP=$(( totalGP + gradePoint )) # add the grade point to the total counter

          printf "%-9s " "${electives[random_electiveIndex]}" # print module code
          ((random_electiveIndex++)) # increment the index
          printf "%-50s " "${electives[random_electiveIndex]}" # print module name
          ((random_electiveIndex++)) # increment the index
          printf "%-4s " "${electives[random_electiveIndex]}" # print credits worth
          totalCredits=$(( totalCredits + electives[random_electiveIndex] )) # add to the total amount of credits earned
          ((random_electiveIndex++)) # increment the index
          printf "%-5s " "$grade" # print grade
          printf "%-4s\n" "$gradePoint" # print grade point
        done
      fi
    fi

    echo "" # print a new line afterwards to make it more readable
}

# Print the transcript
echo "Module    Title                                              Cred Grade G.P"
echo "-------   -------------------------------------------------- ---- ----- ---"

generate_stageInfo "Stage 1" "${minc[0]}" "stage1core[@]" "stage1elective[@]" # generate the transcript for stage 1
generate_stageInfo "Stage 2" "${minc[1]}" "stage2core[@]" "stage2elective[@]" # generate the transcript for stage 2
generate_stageInfo "Stage 3" "${minc[2]}" "stage3core[@]" "stage3elective[@]" "$1" # generate the transcript for stage 3
generate_stageInfo "Stage 4" "${minc[3]}" "stage4core[@]" "stage4elective[@]" # generate the transcript for stage 4

echo "Total grade point score = $totalGP." # Print out the total amount of grade points earned overall
# END SCRIPT