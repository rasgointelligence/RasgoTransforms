def infer_columns(args, source_columns) -> dict:
    if 'end_pos' in args and args['end_pos']:
        source_columns[f"SUBSTRING_{args['target_col']}_{args['start_pos']}_{args['end_pos']}"] = 'varchar'
    else:
        source_columns[f"SUBSTRING_{args['target_col']}_{args['start_pos']}"] = 'varchar'
    return source_columns
