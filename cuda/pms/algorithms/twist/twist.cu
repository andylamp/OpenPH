
inline void twist_step_host(int j, int *h_rows_mp, int *h_low, int m, int p){
    int low_j = h_low[j];
    if (low_j > -1){
        clear_column_host(low_j, h_rows_mp, p);
        h_low[low_j] = -1;
    }
}

inline void twist(int *h_low, int *h_arglow, int *h_classes,
        int *h_ess, int *h_rows_mp, const int m, const int p,
        int *h_dims, int *h_dims_order, int *h_dims_order_next,
        int *h_dims_order_start, int complex_dim,
        int *h_aux_mp, int *h_low_true, int *h_ess_true, float *h_float_m,
        float *error_lone, float *error_linf, float *error_redu,
        float *error_ess, float *time_track, int *p_iter){

    // time
    float time = 0.0;

    // iter and trackers
    track_host(0, m, h_low, h_ess, h_classes,
            h_low_true, h_ess_true, h_float_m,
            error_lone, error_linf, error_redu,
            error_ess, time_track, time);

    // start algo

    int iter = 1;
    for(int dim = complex_dim; dim > 0; dim--){

        int dim_pos = dim+1;
        int j = h_dims_order_start[dim_pos];
        int iterate = 1;

        while (iterate && j > -1){

            // TIC
            clock_t tic = clock();

            // Work on column "j"
            reduce_col_host(j, h_rows_mp, h_aux_mp, h_low, h_arglow, m, p);

            twist_step_host(j, h_rows_mp, h_low, m, p);

            // update classes (Not necessary for algo to work)
            update_classes_host(h_classes, h_low, h_arglow, m);

            // Essential estimation
            ess_hat_host(h_ess, h_low, h_arglow, m);

            // TOC
            clock_t toc = clock();

            // meausre progress
            track_host(iter, m, h_low, h_ess, h_classes,
                    h_low_true, h_ess_true, h_float_m,
                    error_lone, error_linf, error_redu,
                    error_ess, time_track, time);

            // iter
            iter++;

            // Iterator
            if (h_dims_order_next[j] == -1){
                iterate = 0;
            }else{
                j = h_dims_order_next[j];
            }
        }
    } 
    p_iter[0] = iter;


}
