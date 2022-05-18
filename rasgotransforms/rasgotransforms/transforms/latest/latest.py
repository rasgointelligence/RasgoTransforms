def infer_columns(args, source_columns) -> dict:
    out_columns = {}
    for column_name, column_type in source_columns.items():
        if column_name not in args['group_by'] and column_name not in args['order_by']:
            out_columns[f"LATEST_{column_name}"] = column_type
        else:
            out_columns[column_name] = column_type
    return out_columns
