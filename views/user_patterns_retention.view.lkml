view: user_patterns_retention {
  derived_table: {
    sql: SELECT
          order_items.user_id  AS order_items_user_id,
          COUNT(DISTINCT ( TIMESTAMP_TRUNC(order_items.created_at , DAY, 'America/New_York'))) AS count_of_created_date,
          COALESCE(SUM(CASE WHEN NOT COALESCE(( (DATE(order_items.returned_at , 'America/New_York')) IS NOT NULL  ), FALSE) THEN order_items.sale_price  ELSE NULL END), 0) AS order_items_total_gross_revenue
      FROM `thelook.order_items`
           AS order_items
      GROUP BY
          1
      ORDER BY
          2 DESC
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.order_items_user_id ;;
  }




  dimension: total_lifetime_orders {
    description: "Total Lifetime Orders by a Customer"
    type: number
    sql: ${TABLE}.count_of_created_date ;;
  }

  dimension: customer_lifetime_orders {
    description: "Customers grouped/tiered by their lifetime orders."
    type: tier
    tiers: [1,2,5,10]
    style: integer
    sql: ${total_lifetime_orders} ;;
    }

  dimension: total_customers_lifetime_revenue {
    description: "Total Revenue by individual Customer"
    type: number
    sql: ${TABLE}.order_items_total_gross_revenue ;;
    value_format_name: usd
  }

  dimension: customer_lifetime_revenue  {
    description: "Customers grouped/tiered by their lifetime revenue"
    type: tier
    tiers: [5, 20, 50, 100, 500, 1000]
    style: integer
    sql: ${total_customers_lifetime_revenue} ;;
    value_format_name: usd_0
  }

  measure: average_lifetime_orders {
    description: "The average lifetime orders for all customers"
    type: average
    sql: ${total_lifetime_orders};;
    value_format: "0.00"
  }

  measure: average_lifetime_revenue {
    description: "The average lifetime revenue for all customers"
    type: average
    sql: ${total_customers_lifetime_revenue};;
    value_format_name: usd
  }


  set: detail {
    fields: [user_id, total_lifetime_orders, total_customers_lifetime_revenue]
  }
}
