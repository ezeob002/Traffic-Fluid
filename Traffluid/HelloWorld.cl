

__kernel void pepe(__global float *result)
{
    int gid = get_global_id(0);
    
    result[gid] = result[gid] * 2;
}

__kernel void hello_kernel(__global const float *a,
                           __global const float *b,
                           __global float *result)
{
    int gid = get_global_id(0);
    
    result[gid] = a[gid] + b[gid];
    
    pepe(result);
}

__kernel void hello_kernel2(__global const float *a,
                           __global const float *b,
                           __global float *result)
{
    int gid = get_global_id(0);
    
    result[gid] = 0;
}