# The name of this view in Looker is "Order Items"
view: order_items {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `thelook.order_items`
    ;;
  drill_fields: [id]
  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.delivered_at ;;
  }

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Inventory Item ID" in Explore.

  measure: first_order {
    description: "The date in which a customer placed his or her first order on the
fashion.ly website"
    type: date
    sql: MIN(${created_raw}) ;;
  }

  measure: latest_order {
    description: "The date in which a customer placed his or her most recent order
on the fashion.ly website"
    type: date
    sql: MAX(${created_raw}) ;;
  }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: product_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.returned_at ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension: is_item_returned {
    type: yesno
    sql: ${returned_date} IS NOT NULL ;;
  }

  measure: total_gross_revenue{
    description: "Total revenue from completed sales (cancelled and returned orders excluded) "
    type: sum
    sql: ${sale_price};;
    filters: [is_item_returned: "No"]
    value_format_name: usd
  }

  measure: total_gross_margin {
    description: "Amount Total difference between the total revenue from completed sales and the cost of the goods that were sold "
    type: sum
    drill_fields: [inventory_items.product_brand, inventory_items.product_category]
    sql: ${order_items.sale_price} - ${inventory_items.cost} ;;
    value_format_name: usd
  }


  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
  }

  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  dimension_group: shipped {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.shipped_at ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_items_returned {
    description: "Number of items that were returned by dissatisfied customers "
    type: count
    filters: [is_item_returned: "Yes"]
  }


  measure: average_gross_margin {
    description: "Average difference between the total revenue from completed sales and the cost of the goods that were sold "
    type: number
    sql: ${total_gross_margin}/${count} ;;
    value_format_name: usd_0
  }

  measure: gross_margin_percenatage {
    description: "Total Gross Margin Amount / Total Gross Revenue "
    type: number
    sql:100.0 * ${total_gross_margin}/ nullif(${total_gross_revenue}, 0) ;;
    value_format: "0.00\%"
  }

  measure: items_return_rate {
    description: "Number of Items Returned / total number of items sold"
    type: number
    sql: 100.0 * ${total_items_returned}/ ${count} ;;
    value_format: "0.00\%"
  }

  measure: total_customers_with_returned_items {
    description: "Number of users who have returned an item at some point"
    type: count_distinct
    sql: ${user_id} ;;
    filters: [is_item_returned: "Yes"]
  }

  measure: number_of_orders {
    description: "Distinct number of orders"
    type: count_distinct
    sql: ${order_id} ;;
  }



  #  Sets of fields for drilling
  set: detail {
    fields: [
      id,
      users.last_name,
      users.id,
      users.first_name,
      inventory_items.id,
      inventory_items.product_name,
      products.name,
      products.id
    ]
  }
}
