ERA=2017 # 2018 2017
DIR="/eos/cms/store/group/phys_susy/HToaaTo4b/MiniAOD/${ERA}/MC/"
#SAMP="SUSY_GluGluH_01J_HToAATo4B_Pt150"
SAMP="SUSY_TTH_TTToAll_HToAATo4B_Pt150"
for MA in 11.0 11.5 12.5 13.0 13.5 14.0 16.0 17.0 18.5 21.5 23.0 27.5 32.5 37.5 42.5 47.5 52.5 57.5 62.5;
do
    #echo ${SAMP}_M-${MA}
    #ls ${DIR}${SAMP}_M-${MA}*/*/*/*root | wc -l
    #echo -e $(ls ${DIR}${SAMP}_M-${MA}*/*/*/*root | wc -l) ' \t ' $(du -sh ${DIR}${SAMP}_M-${MA}* )  ' \t '   ${SAMP}_M-${MA}
    echo -e ${SAMP}_M-${MA}  ' \t ' $(ls ${DIR}${SAMP}_M-${MA}*/*/*/*root | wc -l) ' \t ' $(du -sh ${DIR}${SAMP}_M-${MA}* )  
    #nFiles=$()
done
#du -sh ${DIR}${SAMP}_M-*
