def infer_columns(args, source_columns) -> dict:
    join_columns = args['source_columns'][args['join_table']]
    if 'join_prefix' in args and args['join_prefix']:
        for col_name, col_type in join_columns.items():
            source_columns[f"{args['join_prefix'].upper()}_{col_name}"] = col_type
        return source_columns
    else:
        return {**source_columns, **join_columns}
