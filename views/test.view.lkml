view: test {
  derived_table: {
    sql: SELECT order_items.user_id  AS user_id,
        --order_items.CREATED_AT AS created_at,
        row_number() over (PARTITION BY user_id ORDER BY created_at) as order_sequence,
        nullifzero(
          datediff(day,
            lag(created_at,1) over (PARTITION BY user_id ORDER BY created_at),
            created_at
            )) as days_between_orders,
        case when lead(created_at,1) over (partition by user_id order by created_at) is not null then 1
             else 0 end as has_subsequent_order,
        case when days_between_orders <= 60 then 1 else 0 end as is_60_day_repeat_purchase
      FROM thelook.order_items as order_items

      GROUP BY 1, 2 ;;

  }


  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: order_sequence {
    description: "The order in which a customer placed orders over their lifetime"
    type: number
    sql: ${TABLE}.order_sequence ;;
  }

  # dimension_group: created_at {
  #   type: time
  #     timeframes: [
  #       raw,
  #       time,
  #       date,
  #       week,
  #       month,
  #       quarter,
  #       year
  #     ]
  #   sql: ${TABLE}.created_at ;;
  # }

  dimension: days_between_orders {
    description: "The number of days between one order and the next order"
    type: number
    sql: ${TABLE}.days_between_orders ;;
  }



}
