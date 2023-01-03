# Key Use Case 2 - Order Sequencing

view: user_patterns_and_facts {
  derived_table: {
    sql: select user_id,
      count(distinct order_id) as lifetime_orders,
       COALESCE(SUM(CASE WHEN NOT COALESCE(( (DATE(order_items.returned_at )) IS NOT NULL  ), FALSE) THEN order_items.sale_price  ELSE NULL END), 0) AS order_items_total_gross_revenue,
       min(created_at) as first_order,
       max(created_at) as last_order
    from order_items
    group by 1 ;;
  }

  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: number_of_orders {
    description: "Total Revenue by individual Customer"
    type: number
    sql: ${TABLE}.lifetime_orders ;;
  }

  dimension: customers_lifetime_revenue {
    type: number
    sql: ${TABLE}.order_items_total_gross_revenue ;;
  }

  dimension_group: lastest_order {
    description: "The date in which a customer placed his or her most recent order on the fashion.ly website"
    type: time
    timeframes: [date,month,year,raw]
    sql: ${TABLE}.last_order ;;
  }

  dimension_group: first_order {
    description: "The date in which a customer placed his or her first order on the fashion.ly website"
    type: time
    timeframes: [date,month,year,raw]
    sql: ${TABLE}.first_order ;;
  }


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # dimension: first_order {
  #   description: "The date in which a customer placed his or her first order on the fashion.ly website"
  #   type: date
  # }

  # dimension: latest_order {
  #   description: "The date in which a customer placed his or her most recent order on the fashion.ly website"
  #   type: date
  # }

  dimension: days_since_last_order {
    description: "The number of days since a customer placed his or her most
    recent order on the website"
    type: number
    sql: DATE_DIFF(current_date(), ${lastest_order_date}, day) ;;
  }


  dimension: active_customer {
    description: "Identifies whether a customer is active or not (has purchased from the website within the last 90 days)"
    type: yesno
    sql: ${days_since_last_order} < 90 ;;
  }

  dimension: repeat_customer {
    description: "Identifies whether a customer was a repeat customer or not"
    type: yesno
    sql: ${number_of_orders} > 1 ;;
  }

  dimension: tiered_customer_lifetime_orders {
    description: "Customers grouped/tiered by their lifetime orders."
    type: tier
    tiers: [1,2,5,10]
    style: integer
    sql: ${number_of_orders} ;;
  }

  dimension: customer_lifetime_revenue_tiered  {
    description: "Customers grouped/tiered by their lifetime revenue"
    type: tier
    tiers: [5, 20, 50, 100, 500, 1000]
    style: integer
    sql: ${customers_lifetime_revenue} ;;
    value_format_name: usd
  }

  measure: average_lifetime_orders {
    description: "The average lifetime orders for all customers"
    type: average
    sql: ${number_of_orders};;
    value_format: "0.00"
  }

  measure: average_lifetime_revenue {
    description: "The average lifetime revenue for all customers"
    type: average
    sql: ${customers_lifetime_revenue};;
    value_format_name: usd
  }

  measure: average_days_since_last_order {
    description: "The average number of days since customers have placed their most recent orders on the website"
    type: average
    sql: ${days_since_last_order} ;;
    value_format: "0"
  }

# Drill Fields
  set: detail {
    fields: [user_id, number_of_orders, customers_lifetime_revenue]
  }
}