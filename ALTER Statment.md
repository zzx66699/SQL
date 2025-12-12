# `ALTER` Statement 

The `ALTER` statement in SQL is used to modify the structure of an existing database object — most commonly a table.  
You use `ALTER TABLE` when you want to change columns, constraints, or metadata without recreating the table.

---

## Add a Column

```sql
ALTER TABLE products
ADD COLUMN unit_price numeric;
```

## Remove a column
```sql
ALTER TABLE products
DROP COLUMN old_field;
```

## Change a Column's Data Type
```sql
ALTER TABLE table_name
ALTER COLUMN column_name TYPE new_type;
```
EXAMPLE
```sql
ALTER TABLE products
ALTER COLUMN sku TYPE text;
```

## Set or Remove a Default Value
Set the default
```sql
ALTER TABLE products
ALTER COLUMN availability SET DEFAULT true;
```
Remove the default
```sql
ALTER TABLE products
ALTER COLUMN availability DROP DEFAULT;
```

## Set or Remove NOT NULL
Require a column to be non-null:
```sql
ALTER TABLE products
ALTER COLUMN sku SET NOT NULL;
```

Allow nulls again:
```sql
ALTER TABLE products
ALTER COLUMN sku DROP NOT NULL;
```

## Add or Remove a UNIQUE Constraint
```sql
ALTER TABLE products
ADD CONSTRAINT products_sku_unique UNIQUE (sku);
```

Drop a constraint:
```sql
ALTER TABLE products
DROP CONSTRAINT products_sku_unique;
```