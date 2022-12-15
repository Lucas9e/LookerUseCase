view: patterns_retention {
  derived_table: {
    sql: SELECT
          order_items.user_id  AS user_id,
          COUNT(DISTINCT order_items.id ) AS patterns_retention_ordered_items_count,
          ROUND(COALESCE(CAST( ( SUM(DISTINCT (CAST(ROUND(COALESCE(CASE WHEN  NOT COALESCE(( (DATE(order_items.returned_at , 'America/New_York')) IS NOT NULL  ), FALSE)  THEN  order_items.sale_price   ELSE NULL END
      ,0)*(1/1000*1.0), 9) AS NUMERIC) + (cast(cast(concat('0x', substr(to_hex(md5(CAST(CASE WHEN  NOT COALESCE(( (DATE(order_items.returned_at , 'America/New_York')) IS NOT NULL  ), FALSE)  THEN  order_items.id   ELSE NULL END
       AS STRING))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(CAST(CASE WHEN  NOT COALESCE(( (DATE(order_items.returned_at , 'America/New_York')) IS NOT NULL  ), FALSE)  THEN  order_items.id   ELSE NULL END
       AS STRING))), 16, 8)) as int64) as numeric)) * 0.000000001 )) - SUM(DISTINCT (cast(cast(concat('0x', substr(to_hex(md5(CAST(CASE WHEN  NOT COALESCE(( (DATE(order_items.returned_at , 'America/New_York')) IS NOT NULL  ), FALSE)  THEN  order_items.id   ELSE NULL END
       AS STRING))), 1, 15)) as int64) as numeric) * 4294967296 + cast(cast(concat('0x', substr(to_hex(md5(CAST(CASE WHEN  NOT COALESCE(( (DATE(order_items.returned_at , 'America/New_York')) IS NOT NULL  ), FALSE)  THEN  order_items.id   ELSE NULL END
       AS STRING))), 16, 8)) as int64) as numeric)) * 0.000000001) )  / (1/1000*1.0) AS FLOAT64), 0), 6) AS order_items_total_gross_revenue
      FROM `thelook.order_items`  AS patterns_retention
      LEFT JOIN `thelook.order_items`
           AS order_items ON patterns_retention.id = order_items.id
      GROUP BY
          1
      ORDER BY
          2 DESC
      LIMIT 500
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: patterns_retention_ordered_items_count {
    type: number
    sql: ${TABLE}.patterns_retention_ordered_items_count ;;
  }

  dimension: order_items_total_gross_revenue {
    type: number
    sql: ${TABLE}.order_items_total_gross_revenue ;;
  }

  dimension: customer_group_by_items_purchased {
    type: tier
    tiers: [1,2,5,10]
    style: integer
    sql: ${patterns_retention_ordered_items_count} ;;
  }



  set: detail {
    fields: [user_id, patterns_retention_ordered_items_count, order_items_total_gross_revenue]
  }
}