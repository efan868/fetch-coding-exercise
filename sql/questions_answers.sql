-- What are the top 5 brands by receipts scanned for most recent month?
select
    brand_name,
    count(distinct receipt_id) as receipt_scanned
from fact_spend_brands
where receipt_scanned_date >= date_trunc('month', current_date)
  and receipt_scanned_date < dateadd('month', 1, date_trunc('month', current_date))
group by brand_name
order by receipt_scanned desc
limit 5;


-- How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?


with recent_data as (
    select
        brand_name,
        date_trunc('month', receipt_scanned_date) as month,
        count(distinct receipt_id) as receipt_scanned
    from fact_spend_brands
    where receipt_scanned_date >= date_trunc('month', dateadd('month', -1, current_date))
    group by 1,2
),
ranked_brands as (
    select
        brand_name,
        month,
        receipt_scanned,
        rank() over (partition by month order by receipt_scanned desc) as rank
    from recent_data
   qualify rank() over (partition by month order by receipt_scanned desc) <= 5
),

select
    fb1.brand_name,
    fb1.month as current_month,
    fb1.rank as current_rank,
    fb1.receipt_scanned as current_receipts,
    fb2.month as previous_month,
    fb2.rank as previous_rank,
    fb2.receipt_scanned as previous_receipts
from ranked_brands fb1
left join ranked_brands fb2
    on fb1.brand_name = fb2.brand_name
    and fb1.month = dateadd('month', 1, fb2.month)
where fb1.month = date_trunc('month', current_date);

---- When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?

select
    rewards_receipt_status,
    avg(total_spent) as average_spend
from fact_spend_total
where rewards_receipt_status in ('Accepted', 'Rejected')
group by 1


-- When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?


select
    rewards_receipt_status,
    count(receipt_item_uuid) as total_items_purchased
from fact_spend_brands
where rewards_receipt_status in ('Accepted', 'Rejected')
group by 1

-- Which brand has the most spend among users who were created within the past 6 months?

select
    brand_name,
    sum(total_spent) as total_spend
from fact_spend_total
where user_created_date >= dateadd('month', -6, current_date)
group by 1
order by 2 desc
limit 1;


--  Which brand has the most transactions among users who were created within the past 6 months?
select
    brand_name,
    count(distinct receipt_id) as total_transactions
from fact_spend_total
where user_created_date >= dateadd('month', -6, current_date)
group by 1
order by 2 desc
limit 1;






