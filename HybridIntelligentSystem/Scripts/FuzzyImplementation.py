import pandas as pd
import numpy as np
import skfuzzy as fuzz
import matplotlib.pyplot as plt

#pip install skfuzzy


#Fuzzy Score calcutation function
def fuzzy_score_calc(age,avg_bal_val,avg_trans_val,income_val):

    age = age
    avg_bal_val = avg_bal_val
    avg_trans_val = avg_trans_val
    income_val = income_val

    #Define fuzzy Range for the variables
    age_range = np.arange(0,100,1)
    income_range = np.arange(350,20000,1)
    avg_bal = np.arange(40,90000,1)
    avg_trans = np.arange(0,10000,1)
    inves_score = np.arange(0,1,0.1)
    acc_inves_score = np.arange(0,4,1)
    income_inves_score = np.arange(0,1,0.1)



    #define fuzzy linguistic terms
    income_lo = fuzz.trimf(income_range,[350,350,7000])
    income_me = fuzz.trimf(income_range,[5000,9000,14000])
    income_hi = fuzz.trimf(income_range,[12000,20000,20000])

    avg_bal_lo = fuzz.trimf(avg_bal,[40,40,7000])
    avg_bal_me = fuzz.trimf(avg_bal,[5000,15000,20000])
    avg_bal_hi = fuzz.trimf(avg_bal,[17000,90000,90000])

    avg_trans_lo = fuzz.trimf(avg_trans,[0,0,2000])
    avg_trans_me = fuzz.trimf(avg_trans,[1500,3000,5000])
    avg_trans_hi = fuzz.trimf(avg_trans,[4000,10000,10000])

    age_lo = fuzz.trimf(age_range,[0,0,30])
    age_me = fuzz.trimf(age_range,[20,45,60])
    age_hi = fuzz.trimf(age_range,[50,100,100])

    inves_lo = fuzz.trimf(inves_score,[0,0,.40])
    inves_me = fuzz.trimf(inves_score,[.30,.50,.70])
    inves_hi = fuzz.trimf(inves_score,[.60,1,1])

    income_inves_lo = fuzz.trimf(inves_score,[0,0,.40])
    income_inves_me = fuzz.trimf(inves_score,[.30,.50,.70])
    income_inves_hi = fuzz.trimf(inves_score,[.60,1,1])

    acc_inves_lo = fuzz.trimf(acc_inves_score,[0,0,2])
    acc_inves_me = fuzz.trimf(acc_inves_score,[1,2,3])
    acc_inves_hi = fuzz.trimf(acc_inves_score,[2,4,4])


    #Map values to fuzzy range via the membership function- fuzzy activation
    age_level_lo = fuzz.interp_membership(age_range,age_lo,age)
    age_level_me = fuzz.interp_membership(age_range,age_me,age)
    age_level_hi = fuzz.interp_membership(age_range,age_hi,age)

    avg_bal_level_lo = fuzz.interp_membership(avg_bal,avg_bal_lo,avg_bal_val)
    avg_bal_level_me = fuzz.interp_membership(avg_bal,avg_bal_me,avg_bal_val)
    avg_bal_level_hi = fuzz.interp_membership(avg_bal,avg_bal_hi,avg_bal_val)

    avg_trans_level_lo = fuzz.interp_membership(avg_trans,avg_bal_lo,avg_trans_val)
    avg_trans_level_me = fuzz.interp_membership(avg_trans,avg_bal_me,avg_trans_val)
    avg_trans_level_hi = fuzz.interp_membership(avg_trans,avg_bal_hi,avg_trans_val)

    income_level_lo = fuzz.interp_membership(income_range,income_lo,income_val)
    income_level_me = fuzz.interp_membership(income_range,income_me,income_val)
    income_level_hi = fuzz.interp_membership(income_range,income_hi,income_val)

    income_acti_lo = np.fmin(income_level_lo,income_inves_lo)
    income_acti_me = np.fmin(income_level_me,income_inves_me)
    income_acti_hi = np.fmin(income_level_hi,income_inves_hi)

    inves_age_acti_lo = np.fmin(age_level_lo,inves_me)
    inves_age_acti_me = np.fmin(age_level_me,inves_hi)
    inves_age_acti_hi = np.fmin(age_level_hi,inves_lo)

    #Apply Rules to the fuzzy ligustic terms
    #high avg_bal and high avg_trans give high investmenxt
    acc_inves_rule1 = np.fmin(avg_bal_level_hi,avg_trans_level_hi)
    acc_inves_rule2 = np.fmin(avg_bal_level_hi,avg_trans_level_me)
    acc_inves_rule3 = np.fmin(avg_bal_level_me,avg_trans_level_hi)
    acc_inves_rule8 = np.fmin(avg_bal_level_hi, avg_trans_level_lo)
    acc_inves_rule9 = np.fmin(avg_bal_level_lo, avg_trans_level_me)
    acc_inves_rule4 = np.fmin(avg_bal_level_me,avg_trans_level_me)
    acc_inves_rule5 = np.fmin(avg_bal_level_lo,avg_trans_level_me)
    acc_inves_rule6 = np.fmin(avg_bal_level_me,avg_trans_level_lo)
    acc_inves_rule7 = np.fmin(avg_bal_level_lo,avg_trans_level_lo)

    acc_inves_acti_hi1 = np.fmin(acc_inves_rule1,acc_inves_hi)
    acc_inves_acti_hi2 = np.fmin(acc_inves_rule2, acc_inves_hi)
    acc_inves_acti_hi3 = np.fmin(acc_inves_rule3, acc_inves_hi)
    acc_inves_acti_me1 = np.fmin(acc_inves_rule8,acc_inves_me)
    acc_inves_acti_me2 = np.fmin(acc_inves_rule9,acc_inves_me)
    acc_inves_acti_me3 = np.fmin(acc_inves_rule4,acc_inves_me)
    acc_inves_acti_lo1 = np.fmin(acc_inves_rule5,acc_inves_lo)
    acc_inves_acti_lo2 = np.fmin(acc_inves_rule6,acc_inves_lo)
    acc_inves_acti_lo3 = np.fmin(acc_inves_rule7,acc_inves_lo)

    acc_inves_hi_max = np.fmax(acc_inves_acti_hi1, np.fmax(acc_inves_acti_hi3, acc_inves_acti_hi2))
    acc_inves_me_max = np.fmax(acc_inves_acti_me1,np.fmax(acc_inves_acti_me3,acc_inves_acti_me2))
    acc_inves_lo_max = np.fmax(acc_inves_acti_lo1,np.fmax(acc_inves_acti_lo3,acc_inves_acti_lo2))

    #Aggregate Rules
    acc_inves_aggregated = np.fmax(acc_inves_hi_max,np.fmax(acc_inves_me_max,acc_inves_lo_max))
    age_aggregated = np.fmax(inves_age_acti_lo,np.fmax(inves_age_acti_me,inves_age_acti_hi))
    income_aggregated = np.fmax(income_acti_lo,np.fmax(income_acti_me,income_acti_hi))

    #Defuzzy
    age_inves = fuzz.defuzz(inves_score, age_aggregated, 'centroid')
    acc_inves = fuzz.defuzz(acc_inves_score,acc_inves_aggregated,'centroid')
    income_inves = fuzz.defuzz(income_inves_score,income_aggregated,'centroid')
    return  acc_inves,age_inves,income_inves


#Crisp rule calcuation function
def crispScoreCalc(occup,gender,mstatus,edu):
    occup = occup
    gender = gender
    mstatus = mstatus
    edu = edu

    if(mstatus == "married"):
        if(gender == "M"):
            gn_score=0.7
        else:
            gn_score=0.2
    else:
        if(gender == "M"):
            gn_score=0.7
        else:
            gn_score=0.4

    if(occup in ["IT","construct","finance"]):
        occup_score = 0.6
    elif(occup in ["medicine"]):
        occup_score = 0.7
    elif(occup in ["education","government","manuf"]):
        occup_score = 0.4
    elif(occup in ["retired"]):
        occup_score = 0.1
    else:
        occup_score = 0.8

    if(edu == 'postgrad'):
        edu_score = 0.5
    elif(edu == 'professional'):
        edu_score = 0.7
    elif(edu == 'secondary'):
        edu_score = -0.3
    else:
        edu_score = -0.2
    return gn_score,occup_score,edu_score


def profit_calc(decision,score):
    if (decision == "None"):
        return 0
    elif (decision == "A"):
        return score*0.6
    else:
        return score


data = pd.read_csv("custdatabase_edited.csv")
for index,row in data.iterrows():
    gn_score, occup_score,edu_score = crispScoreCalc(row['occupation'], row['sex'], row['mstatus'],row['education'])
    acc_inves, age_inves, income_inves = fuzzy_score_calc(row['age'],row['avbal'],row['avtrans'],row['income'])
    final_score = gn_score+occup_score+acc_inves+ age_inves+income_inves+edu_score
    data.loc[index,'Predicted Score'] = final_score
    data.loc[index,'abs Difference'] =abs(row['cust Investment Potential Score'] - final_score)
    data.loc[index,'Gender Score'] = gn_score
    data.loc[index,'Occupation Score']= occup_score
    data.loc[index,'Account Score'] = acc_inves
    data.loc[index,'Age Score'] = age_inves
    data.loc[index,'Income Score'] = income_inves
    data.loc[index,'predicted profit Score'] = profit_calc(row['Predicted Decision'],data.loc[index,'Predicted Score'])
    data.loc[index,'Actual profit Score'] = profit_calc(row['decision'],row['cust Investment Potential Score'])
    print("Index :",row['index'],"   PredictedScore :",final_score,"  ActualScore :",row['cust Investment Potential Score'])

predictedDF = data.sort_values(by='predicted profit Score',ascending=False)
actualDF = data.sort_values(by='Actual profit Score',ascending=False)
predictedDF = predictedDF.head(400)
actualDF = actualDF.head(400)
print("Acual Profit:",sum(actualDF['Actual profit Score']))
print("Predicted Profit",sum(predictedDF['predicted profit Score']))

data.to_csv("customerScoreResults.csv")
predictedDF.to_csv("Top400Results.csv")
