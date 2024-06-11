import time
import requests
import uuid
import matplotlib.pyplot as plt
import numpy as np
from concurrent.futures import ThreadPoolExecutor, as_completed

def send_request(source_img_url):
    headers = {
        "Device-Id": str(uuid.uuid4())
    }

    data = {
        "source_img_path": source_img_url
    }

    start_time = time.time()
    response = requests.post("https://vohuynh19-animegan-server.hf.space/v2/ml/anime", json=data, headers=headers)
    end_time = time.time()

    response_time = end_time - start_time
    return response_time, response.status_code

def test_endpoint_parallel(source_img_url, num_tests=10, num_parallel=20):
    response_times = []

    with ThreadPoolExecutor(max_workers=num_parallel) as executor:
        futures = [executor.submit(send_request, source_img_url) for _ in range(num_tests)]

        for i, future in enumerate(as_completed(futures)):
            response_time, status_code = future.result()
            response_times.append(response_time)

            if status_code == 200:
                print(f"Request {i+1} succeeded in {response_time:.2f} seconds.")
            else:
                print(f"Request {i+1} failed with status code {status_code}.")

    return response_times

def plot_response_times(times, response_times):
    plt.figure(figsize=(10, 6))
    plt.plot(times, response_times, marker='o', linestyle='-', color='b')
    plt.xlabel('Times')
    plt.ylabel('Response Times (seconds)')
    plt.title('Endpoint Response Times Over Multiple Runs')
    plt.grid(True)
    plt.ylim(0)
    plt.savefig('response_times_chart.png')
    plt.show()
    print("Chart saved as response_times_chart.png")

# Parameters
source_img_url = "https://firebasestorage.googleapis.com/v0/b/ios-entertainment-photography.appspot.com/o/806187AA-DC94-40AD-BF52-8C20538B8A32-200102%2Fraw%2F1717311301.jpg?alt=media&token=64cab261-cf17-4e7d-9313-954b26f0ed87"
num_tests = 20
num_parallel = 20

# Run the tests and collect response times
response_times = test_endpoint_parallel(source_img_url, num_tests, num_parallel)

# Generate times for x-axis
times = np.arange(1, num_tests + 1)

# Plot the results and save to a PNG file
plot_response_times(times, response_times)
