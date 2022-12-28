view: cohort {
  derived_table: {
    explore_source: order_items {
      column: user_id {}
      column: order_id {}
      column: created_date {}
      derived_column: order_sequence {
        sql: rank() over (partition by user_id order by created_date);;
      }
      derived_column: days_between_orders {
        sql: date_diff(created_date, lag(created_date,1) over (PARTITION BY user_id ORDER BY created_date), day) ;;
      }
    }
  }
  dimension: user_id {
    primary_key: yes
    description: ""
    type: number
  }

  dimension: order_id {
    description: ""
    type: number
  }

  dimension: created_date {
    description: ""
    type: date
  }

  dimension: order_sequence {
    description: ""
    type: number
  }

  dimension: days_between_orders {
    description: ""
    type: number
  }

  measure: avg_days_between_orders {
    type: average
    sql: ${days_between_orders} ;;
  }
}
