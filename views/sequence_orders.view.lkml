view: sequence_orders {
  view_label: "Sequence of Orders"
  derived_table: {
    sql: SELECT
    order_items.order_id as order_id,
    order_items.created_at,
    order_items.user_id as user_id,
    RANK() over (PARTITION BY order_items.user_id ORDER BY order_items.created_at ASC) as order_sequence,
    COUNT(DISTINCT repeat_order_items.id) AS number_subsequent_orders,
    MIN(repeat_order_items.created_at) AS next_order_date,
    MIN(repeat_order_items.order_id) AS next_order_id
    FROM order_items as order_items
    LEFT JOIN order_items repeat_order_items
      ON order_items.user_id = repeat_order_items.user_id
      AND order_items.created_at
      < repeat_order_items.created_at
    GROUP BY 1, 2, 3  ;;
  }

  dimension: order_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: order_sequence {
    type: number
    sql: ${TABLE}.order_sequence ;;
  }

  dimension: number_subsequent_orders {
    type: number
    sql: ${TABLE}.number_subsequent_orders ;;

  }

  dimension: has_subsequent_order {
    type: yesno
    sql: ${next_order_id} IS NOT NULL ;;
  }

  dimension: next_order_id {
    type: number
    sql: ${TABLE}.next_order_id ;;
  }

  dimension_group: next_order {
    type: time
    timeframes: [raw, date]
    sql: CAST(${TABLE}.next_order_date AS TIMESTAMP) ;;
  }

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
    sql: ${TABLE}.created_at  ;;
  }

  dimension_group: between_next_order {
    type: duration
    intervals: [day]
    sql_start: ${created_raw} ;;
    sql_end: ${next_order_raw} ;;
  }

  # dimension: days_between_next_order {
  #   description: "The number of days between one order and the next order"
  #   type: number
  #   sql: DATE_DIFF(${next_order_date}, ${created_date}, day) ;;
  # }

  measure: total_avg_days_between_orders{
    type: sum
    hidden: yes
    filters: []
  }

  measure: average_days_between_orders {
    type: average
    # filters: [has_subsequent_order: "yes"]
    sql: ${days_between_next_order} ;;
    value_format: "0.00"
  }

}
