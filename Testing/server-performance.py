import time
import requests
import uuid
import matplotlib.pyplot as plt
import numpy as np

def test_endpoint(source_img_url, num_tests=10):
    response_times = []

    for _ in range(num_tests):
        # Generate a unique Device-Id for each request
        headers = {
            "Device-Id": str(uuid.uuid4())
        }

        # Prepare the request payload
        data = {
            "source_img_path": source_img_url
        }

        # Measure the response time
        start_time = time.time()
        response = requests.post("https://vohuynh19-animegan-server.hf.space/v2/ml/anime", json=data, headers=headers)
        end_time = time.time()

        response_time = end_time - start_time
        response_times.append(response_time)

        if response.status_code == 200:
            print(f"Request {_+1} succeeded in {response_time:.2f} seconds.")
        else:
            print(f"Request {_+1} failed with status code {response.status_code}.")

    return response_times

def plot_response_times(times, response_times):
    # Plot the results
    plt.figure(figsize=(10, 6))
    plt.plot(times, response_times, marker='o', linestyle='-', color='b')
    plt.xlabel('Times')
    plt.ylabel('Response Times (seconds)')
    plt.title('Endpoint Response Times Over Multiple Runs')
    plt.grid(True)
    plt.savefig('response_times_chart.png')
    plt.show()
    print("Chart saved as response_times_chart.png")

# Parameters
source_img_url = "https://firebasestorage.googleapis.com/v0/b/ios-entertainment-photography.appspot.com/o/806187AA-DC94-40AD-BF52-8C20538B8A32-200102%2Fraw%2F1717311301.jpg?alt=media&token=64cab261-cf17-4e7d-9313-954b26f0ed87"
num_tests = 10

# Run the tests and collect response times
response_times = test_endpoint(source_img_url, num_tests)

# Generate times for x-axis
times = np.arange(1, num_tests + 1)

# Plot the results and save to a PNG file
plot_response_times(times, response_times)
