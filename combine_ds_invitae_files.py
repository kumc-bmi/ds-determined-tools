# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:light
#     text_representation:
#       extension: .py
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.11.4
#   kernelspec:
#     display_name: Python 3 (ipykernel)
#     language: python
#     name: python3
# ---

# +
'''
single_ds_file.py:
    usage: python combine_ds_invitae_files.py invitae output/invitae_14csv_in1.csv
    
    Create single ds file from 14 csv files.
    1. Only select 1 site data. eg. KUMC patient start with SA
    2. Sruvey is complete
    3. if there is multiple comlete response pick the last one 
    
'''
from os import listdir
from os.path import join
from sys import argv

import pandas as pd


def create_single_ds_csv(csv_input_dir, csv_output_path):

    files = listdir(csv_input_dir)
    csv_files = [f for f in files if f.endswith('.csv')]

    dfs = {}
    dfs_len = {}
    dfs_cols = {}
    for f in csv_files:

        df = pd.read_csv(join(csv_input_dir, f), low_memory=False)

        # filter data
        df = df[
            # survey starts with sit id
            df.subject_id.str.startswith('SA').fillna(False)
            # survey is compelete
            & (df.survey_complete == 1).fillna(False)
        ]

        # only keep latest records
        if len(df.subject_id.tolist()) != len(df.subject_id.unique().tolist()):
            print(f'User has finished survey multiple times in {f}')
            df = df.sort_values(['subject_id', 'survey_time']).drop_duplicates(
                ['subject_id'], keep='last')

        # set index so it can be joined using it
        df = df.set_index(['org_name', 'patient_id', 'subject_id'])
        dfs[f] = df

        dfs_len[f] = len(df)
        dfs_cols[f] = set(df.columns.tolist())

    # -

    output_df = dfs['DS_Determined_IHQ_Survey.csv'].join(
        dfs['DS_Determined_AdultQuestionnaire.csv'], how='left', rsuffix='_Adult').join(
        dfs['DS_Determined_WomensHealth_Questionnaire.csv'], how='left', rsuffix='_WomensHealth').join(
        dfs['DS_Determined_Sleep_Questionnaire.csv'], how='left', rsuffix='_Sleep').join(
        dfs['DS_Determined_Sibling_Questionnaire.csv'], how='left', rsuffix='_Sibling').join(
        dfs['DS_Determined_Skeletal_Questionnaire.csv'], how='left', rsuffix='_Skeletal').join(
        dfs['DS_Determined_MensHealth_Questionnaire.csv'], how='left', rsuffix='_MensHealth').join(
        dfs['DS_Determined_PrenatalandHistory_Questionnaire.csv'], how='left', rsuffix='_PrenatalandHistory').join(
        dfs['DS_Determined_Development_Questionnaire.csv'], how='left', rsuffix='_Development').join(
        dfs['DS_Determined_Leukemia_Questionnaire.csv'], how='left', rsuffix='_Leukemia').join(
        dfs['DS_Determined_Heart_Questionnaire.csv'], how='left', rsuffix='_Heart').join(
        dfs['DS_Determined_Thyroid_Questionnaire.csv'], how='left', rsuffix='_Thyroid').join(
        dfs['DS_Determined_Gastronintestinal_Survey.csv'], how='left', rsuffix='_Gastronintestinal').join(
        dfs['DS_Determined_TransitionAdulthood_Questionnaire.csv'], how='left', rsuffix='TransitionAdulthood')

    output_df = output_df.reset_index()

    output_df.to_csv(csv_output_path)


if __name__ == '__main__':
    [csv_input_dir, csv_output_path] = argv[1:3]
    create_single_ds_csv(csv_input_dir, csv_output_path)
    # usage: make combine_ds_invitae_files
