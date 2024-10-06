{
    "extensions": [
        "data_fetcher",
        "difficulty_sampler",
        "submissions_manager",
        "job_manager",
        "precommit_manager",
        "slave_manager"
    ],
    "config": {
        "job_manager": {
            "satisfiability": {
                "batch_size": 2
            },
            "vehicle_routing": {
                "batch_size": 2
            },
            "knapsack": {
                "batch_size": 1000
            },
            "vector_search": {
                "batch_size": 2
            }
        },
        "precommit_manager": {
            "max_unresolved_precommits": 5,
            "algo_selection": {
                "satisfiability": {
                    "algorithm": "sat_global",
                    "num_nonces": 2,
                    "base_fee_limit": "10000000000000000"
                },
                "vehicle_routing": {
                    "algorithm": "cw_heuristic",
                    "num_nonces": 10,
                    "base_fee_limit": "10000000000000000"
                },
                "knapsack": {
                    "algorithm": "knapheudp",
                    "num_nonces": 131072,
                    "base_fee_limit": "10000000000000000"
                },
                "vector_search": {
                    "algorithm": "invector",
                    "num_nonces": 2,
                    "base_fee_limit": "10000000000000000"
                }
            }
        },
        "slave_manager": {
            "slaves": [
                {
                    "name_regex": ".*",
                    "challenge_selection": null
                }
            ]
        }
    }
}
