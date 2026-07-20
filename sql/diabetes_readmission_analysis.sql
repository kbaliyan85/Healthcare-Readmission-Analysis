-- ==========================================================
-- Healthcare Readmission Analysis
-- Objective:
-- Identify factors affecting 30-day hospital readmissions
-- and provide insights to reduce unnecessary readmissions.
-- ==========================================================



use diabetes;
describe diabetic_data_cleaned;
select * 
from diabetic_data_cleaned
limit 10;



-- BASIC ANALYSIS 

-- total patients 
select count(*) as total_patients
from diabetic_data_cleaned;

-- gender distribution
select gender,count(*) as gender_dist 
from diabetic_data_cleaned
group by gender 
order by count(*) desc;

-- race distribution
select race, count(*) as race_dist
from diabetic_data_cleaned
group by race
order by race_dist desc;

-- age distrubution 
select age , count(*) as age_dist
from diabetic_data_cleaned
group by age
order by age_dist desc; 





-- DEEP ANALYSIS 

-- overall readmission distribution rate 
select readmitted, count(*) as readm_dist,round(count(*) * 100.0 / sum(count(*)) over() , 2) as percentage
from diabetic_data_cleaned
group by readmitted
order by readm_dist desc ;



-- avg hospital stay influencing readmissions?
select round(avg(time_in_hospital),2) as avg_stay,  readmitted
from diabetic_data_cleaned
group by  readmitted
order by avg_stay desc;         
-- key finding: Longer hospital stays are associated with a higher likelihood of readmission.   


  
-- age affecting readmissions
select age , count(*) as total_encounters,
sum( case when readmitted='<30' then 1 else 0 end) as early_encounters,
round(
sum(case when readmitted='<30' then 1 else 0 end) * 100.0/count(*),2) as readmission_rate
from diabetic_data_cleaned
group by age 
order by age desc;
-- key finding: Older people within [60-90] age group contributed to highest number of readmissions



-- gender influence on readmissions
select gender, count(*) as total_encounters,
sum(case when readmitted='<30' then 1 else 0 end ) as early_readmissions,
round(
sum(case when readmitted='<30' then 1 else 0 end )* 100.0/ count(*),2) as readmission_rate
from diabetic_data_cleaned
group by gender;
-- key finding: Gender doesn't appear to be a strong predictor of 30 day hospital readmission.


-- no of diagnoistic on readmission 
select readmitted, round(avg(number_diagnoses),2) as avg_diagnosis 
from diabetic_data_cleaned
group by readmitted;

-- no of medicines 
select readmitted, round(avg(num_medications),2) as avg_medications
from diabetic_data_cleaned
group by readmitted;


-- no of procedures 
select readmitted, round(avg(num_procedures),2) as avg_procedures
from diabetic_data_cleaned
group by readmitted;

-- emergency admsn 
select admission_type_id, readmitted, COUNT(*) as patients
from  diabetic_data_cleaned
group by admission_type_id, readmitted;
 
 
-- primary diagonsis 
select diag_1,count(*) as readmitted_patients
from  diabetic_data_cleaned
where readmitted = '<30'
group by diag_1
order by readmitted_patients desc
limit 10;
 -- heart failure was the most common primary diagnosis among patients readmitted within 30 days, followed by coronary artery disease and heart attack.
-- 428 = Heart Failure
-- 414 = Coronary Artery Disease
-- 410 = Acute Myocardial Infarction

-- ranking diagnosis 
with  diagnosis_counts as (select diag_1, count(*) as readmissions
    from diabetic_data_cleaned
    where readmitted = '<30'
    group by  diag_1
)
select  *,
   DENSE_RANK() over(order by  readmissions desc) as diagnosis_rank
from diagnosis_counts;




-- high risk patients
with patient_summary as (
select patient_nbr, count(*) as total_visits,
        sum(case when readmitted = '<30' then 1 else 0 end )as early_readmissions
    from diabetic_data_cleaned
   group by  patient_nbr
)
select *
from patient_summary
where total_visits > 5
order by  early_readmissions desc, total_visits desc;
-- key info : patients with more frequents visits should require proactive care management.


-- =====================================================
-- SUMMARY OF FINDINGS

-- 1. Around 11% of encounters resulted in readmission within 30 days.

-- 2. Patients aged 60–90 years accounted for the largest number of early readmissions.

-- 3. Longer hospital stays were associated with higher readmission.

-- 4. Gender showed little difference in 30-day readmission rates.

-- 5. Heart failure was the leading diagnosis associated with early readmissions.

-- 6. Patients with frequent hospital encounters may benefit from proactive care management.
-- =====================================================