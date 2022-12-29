view: sql_runner_query {
  derived_table: {
    sql: SELECT
          (DATE(inventory_items.created_at )) AS inventory_items_created_date,
          inventory_items.product_brand  AS inventory_items_product_brand,
          inventory_items.product_category  AS inventory_items_product_category,
          inventory_items.product_department  AS inventory_items_product_department,
          inventory_items.cost  AS inventory_items_cost,
          inventory_items.product_retail_price  AS inventory_items_product_retail_price
      FROM `thelook.order_items`
           AS order_items
      LEFT JOIN `thelook.inventory_items`
           AS inventory_items ON order_items.inventory_item_id = inventory_items.id
      GROUP BY
          1,
          2,
          3,
          4,
          5,
          6
      ORDER BY
          1 DESC
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: inventory_items_created_date {
    type: date
    datatype: date
    sql: ${TABLE}.inventory_items_created_date ;;
  }

  dimension: inventory_items_product_brand {
    type: string
    sql: ${TABLE}.inventory_items_product_brand ;;
  }

  dimension: inventory_items_product_category {
    type: string
    sql: ${TABLE}.inventory_items_product_category ;;
  }

  dimension: inventory_items_product_department {
    type: string
    sql: ${TABLE}.inventory_items_product_department ;;
  }

  dimension: inventory_items_cost {
    type: number
    sql: ${TABLE}.inventory_items_cost ;;
  }

  dimension: inventory_items_product_retail_price {
    type: number
    sql: ${TABLE}.inventory_items_product_retail_price ;;
  }

  set: detail {
    fields: [
      inventory_items_created_date,
      inventory_items_product_brand,
      inventory_items_product_category,
      inventory_items_product_department,
      inventory_items_cost,
      inventory_items_product_retail_price
    ]
  }
}
