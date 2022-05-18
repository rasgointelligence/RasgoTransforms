def infer_columns(args, source_columns) -> dict:
    if 'overwrite_columns' in args and args['overwrite_columns']:
        overwrite_columns = True
    else:
        overwrite_columns = False
    for column_name, column_type in source_columns.items():
        if column_name in args['dates']:
            if overwrite_columns:
                source_columns[column_name] = 'date'
            else:
                source_columns[f"{column_name}_DATE"] = 'date'
    return source_columns
