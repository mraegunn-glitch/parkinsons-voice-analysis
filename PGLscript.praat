#######################################
# Welcome! Please use the script below 
# [written by Melissa Rae Gunning, 6 Dec 2025]
# input: folder of containing 81 .wav files of sustained /a/
# output: .csv file for analysis in R
#######################################


#################
# USER SETTINGS #
#################
soundDirectory$ = chooseDirectory$: "Select folder containing PD and HC"

root$ = soundDirectory$
pdDir$ = root$ + "/PD/"
hcDir$ = root$ + "/HC/"

outputCSV$ = root$ + "/voice_measures.csv"
##############################################

# Create an empty Praat table with the variables you want
Create Table with column names: "VoiceMeasures", 0,
..."filename group duration meanF0 sdF0 jitterLocal jitterAbs rap ppq5 shimmerLocal apq3 apq5 apq11 hnr nhr"

#######################
##### PD patients #####
#######################

Create Strings as file list: "pdList", pdDir$ + "*.wav"
pdCount = Get number of strings

for i from 1 to pdCount
    selectObject: "Strings pdList"
    wav$ = Get string: i
    fullPath$ = pdDir$ + wav$
    
    # Read sound
    Read from file: fullPath$
    soundName$ = selected$("Sound")
    
    # Duration
    duration = Get total duration
    
    #######################################
    # Create objects required for features
    #######################################
    # Pitch
    To Pitch: 0.0, 75, 500
    pitchName$ = selected$("Pitch")
    meanF0 = Get mean: 0, 0, "Hertz"
    sdF0   = Get standard deviation: 0, 0, "Hertz"

    # PointProcess for jitter & shimmer
    selectObject: "Sound " + soundName$
    To PointProcess (periodic, cc): 75, 600
    ppName$ = selected$("PointProcess")
    
    # Jitter measures
    jitterLocal     = Get jitter (local): 0, 0, 0.0001, 0.02, 1.3
    jitterAbs       = Get jitter (local, absolute): 0, 0, 0.0001, 0.02, 1.3
    rap             = Get jitter (rap): 0, 0, 0.0001, 0.02, 1.3
    ppq5            = Get jitter (ppq5): 0, 0, 0.0001, 0.02, 1.3

    # Shimmer measures
    selectObject: "Sound " + soundName$
    plusObject: "PointProcess " + soundName$
    shimmerLocal    = Get shimmer (local): 0, 0, 0.0001, 0.02, 1.3, 1.6
    apq3            = Get shimmer (apq3): 0, 0, 0.0001, 0.02, 1.3, 1.6
    apq5            = Get shimmer (apq5): 0, 0, 0.0001, 0.02, 1.3, 1.6
    apq11           = Get shimmer (apq11): 0, 0, 0.0001, 0.02, 1.3, 1.6

    # Harmonicity (for HNR)
    selectObject: "Sound " + soundName$
    To Harmonicity (cc): 0.01, 75, 0.1, 1.0
    hnr = Get mean: 0, 0

    # Noise-to-Harmonics Ratio (NHR)
    selectObject: "Sound " + soundName$
    To Intensity: 75, 0, "yes"
    # Here we compute a simple inverse-harmonicity estimate:
    if hnr <> 0
        nhr = 1 / hnr
    else
        nhr = undefined
    endif

    ###################################
    # Add row to Praat table
    ###################################
    selectObject: "Table VoiceMeasures"
    Append row
    
    Set string value: i, "filename", wav$
    Set string value: i, "group", "PwPD"
    Set numeric value: i, "duration", duration
    Set numeric value: i, "meanF0", meanF0
    Set numeric value: i, "sdF0", sdF0
    Set numeric value: i, "jitterLocal", jitterLocal
    Set numeric value: i, "jitterAbs", jitterAbs
    Set numeric value: i, "rap", rap
    Set numeric value: i, "ppq5", ppq5
    Set numeric value: i, "shimmerLocal", shimmerLocal
    Set numeric value: i, "apq3", apq3
    Set numeric value: i, "apq5", apq5
    Set numeric value: i, "apq11", apq11
    Set numeric value: i, "hnr", hnr
    Set numeric value: i, "nhr", nhr

    #########
    # CLEAN #
    #########
    select all
    minusObject: "Table VoiceMeasures"
    minusObject: "Strings pdList"
    Remove
endfor

##################################
####### healthy controls #########
##################################

Create Strings as file list: "hcList", hcDir$ + "*.wav"
hcCount = Get number of strings

for i from 1 to hcCount
    selectObject: "Strings hcList"
    wav$ = Get string: i
    fullPath$ = hcDir$ + wav$
    
    # Read sound
    Read from file: fullPath$
    soundName$ = selected$("Sound")
    
    # Duration
    duration = Get total duration
    
    #######################################
    # Create objects required for features
    #######################################
    # Pitch
    To Pitch: 0.0, 75, 500
    pitchName$ = selected$("Pitch")
    meanF0 = Get mean: 0, 0, "Hertz"
    sdF0   = Get standard deviation: 0, 0, "Hertz"

    # PointProcess for jitter & shimmer
    selectObject: "Sound " + soundName$
    To PointProcess (periodic, cc): 75, 600
    ppName$ = selected$("PointProcess")
    
    # Jitter measures
    jitterLocal     = Get jitter (local): 0, 0, 0.0001, 0.02, 1.3
    jitterAbs       = Get jitter (local, absolute): 0, 0, 0.0001, 0.02, 1.3
    rap             = Get jitter (rap): 0, 0, 0.0001, 0.02, 1.3
    ppq5            = Get jitter (ppq5): 0, 0, 0.0001, 0.02, 1.3

    # Shimmer measures
    selectObject: "Sound " + soundName$
    plusObject: "PointProcess " + soundName$
    shimmerLocal    = Get shimmer (local): 0, 0, 0.0001, 0.02, 1.3, 1.6
    apq3            = Get shimmer (apq3): 0, 0, 0.0001, 0.02, 1.3, 1.6
    apq5            = Get shimmer (apq5): 0, 0, 0.0001, 0.02, 1.3, 1.6
    apq11           = Get shimmer (apq11): 0, 0, 0.0001, 0.02, 1.3, 1.6

    # Harmonicity (for HNR)
    selectObject: "Sound " + soundName$
    To Harmonicity (cc): 0.01, 75, 0.1, 1.0
    hnr = Get mean: 0, 0

    # Noise-to-Harmonics Ratio (NHR)
    selectObject: "Sound " + soundName$
    To Intensity: 75, 0, "yes"
    # Here we compute a simple inverse-harmonicity estimate:
    if hnr <> 0
        nhr = 1 / hnr
    else
        nhr = undefined
    endif

    ###################################
    # Add row to Praat table
    ###################################
    selectObject: "Table VoiceMeasures"
    row = i + pdCount
    Append row
    
    Set string value: row, "filename", wav$
    Set string value: row, "group", "HC"
    Set numeric value: row, "duration", duration
    Set numeric value: row, "meanF0", meanF0
    Set numeric value: row, "sdF0", sdF0
    Set numeric value: row, "jitterLocal", jitterLocal
    Set numeric value: row, "jitterAbs", jitterAbs
    Set numeric value: row, "rap", rap
    Set numeric value: row, "ppq5", ppq5
    Set numeric value: row, "shimmerLocal", shimmerLocal
    Set numeric value: row, "apq3", apq3
    Set numeric value: row, "apq5", apq5
    Set numeric value: row, "apq11", apq11
    Set numeric value: row, "hnr", hnr
    Set numeric value: row, "nhr", nhr

    #########
    # CLEAN #
    #########
    select all
    minusObject: "Table VoiceMeasures"
    minusObject: "Strings pdList"
    minusObject: "Strings hcList"
    Remove
endfor


# Write to CSV
selectObject: "Table VoiceMeasures"
Save as comma-separated file: outputCSV$