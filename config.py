PLAYER_ID = "0x5de35f527176887b1b42a2703ba4d64e62a48de4" # your player_id
API_KEY = "3de214b978b22a7b9c0957ccfc3a95a1" # your api_key
TIG_WORKER_PATH = "/root/tig-monorepo/target/release/tig-worker" # path to executable tig-worker
TIG_ALGORITHMS_FOLDER = "/root/tig-monorepo/tig-algorithms" # path to tig-algorithms folder
API_URL = "https://mainnet-api.tig.foundation"

if PLAYER_ID is None or API_KEY is None or TIG_WORKER_PATH is None or TIG_ALGORITHMS_FOLDER is None:
    raise Exception("Please set the PLAYER_ID, API_KEY, and TIG_WORKER_PATH, TIG_ALGORITHMS_FOLDER variables in 'tig-benchmarker/master/config.py'")

PORT = 5115
JOBS = dict(
    # add an entry for each challenge you want to benchmark
    satisfiability=dict(
        # add an entry for each algorithm you want to benchmark
        sat_optima=dict(
            benchmark_duration=10000, # amount of time to run the benchmark in milliseconds
            wait_slave_duration=5000, # amount of time to wait for slaves to post solutions before submitting
            num_jobs=10, # number of jobs to create. each job will sample its own difficulty
            weight=1.0, # weight of jobs for this algorithm. more weight = more likely to be picked
        )
    ),
    vehicle_routing=dict(
        cw_heuristic=dict(
            benchmark_duration=10000,
            wait_slave_duration=5000,
            num_jobs=1,
            weight=1.0,
        )
    ),
    knapsack=dict(
        quick_knap=dict(
            benchmark_duration=10000,
            wait_slave_duration=5000,
            num_jobs=10,
            weight=1.0,
        )
    ),
    vector_search=dict(
        optimax_gpu=dict(
            benchmark_duration=30000, # recommend a high duration
            wait_slave_duration=30000, # recommend a high duration
            num_jobs=1,
            weight=1.0,
        )
    ),
)
