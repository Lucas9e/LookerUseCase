view: user_patterns_and_facts {
  derived_table: {
    explore_source: order_items {
      column: user_id {}
      column: first_order {}
      column: latest_order {}
      column: number_of_orders {}
      column: total_customers_lifetime_revenue { field: order_items.total_gross_revenue }
    }
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_id {
    primary_key: yes
    type: number
  }

  dimension: first_order {
    description: "The date in which a customer placed his or her first order on the
fashion.ly website"
    type: date
  }

  dimension: latest_order {
    description: "The date in which a customer placed his or her most recent order
on the fashion.ly website"
    type: date
  }

  dimension: days_since_last_order {
    description: "The number of days since a customer placed his or her most
    recent order on the website"
    type: number
    sql: DATE_DIFF(current_date(), ${latest_order}, day) ;;
  }

  dimension: number_of_orders {
    description: "Total Lifetime Orders by a Customer"
    type: number
  }

  dimension: active_customer {
    description: "Identifies whether a customer is active or not (has purchased from
the website within the last 90 days)"
    type: yesno
    sql: ${days_since_last_order} < 90 ;;
  }

  dimension: total_customers_lifetime_revenue {
    description: "Total Revenue by individual Customer"
    type: number
    value_format_name: usd
  }

  dimension: customer_lifetime_orders {
    description: "Customers grouped/tiered by their lifetime orders."
    type: tier
    tiers: [1,2,5,10]
    style: integer
    sql: ${number_of_orders} ;;
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
    sql: ${number_of_orders};;
    value_format: "0.00"
  }

  measure: average_lifetime_revenue {
    description: "The average lifetime revenue for all customers"
    type: average
    sql: ${total_customers_lifetime_revenue};;
    value_format_name: usd
  }


# Drill Fields
  set: detail {
    fields: [user_id, number_of_orders, total_customers_lifetime_revenue]
  }
}
