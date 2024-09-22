import { useEffect, useState } from "react";
import Masonry, { ResponsiveMasonry } from "react-responsive-masonry";
import axios from "axios";
import values from "@/config/words.json";
import { getRandomItem } from "@/utils/getRandomItem";
import { Header } from "@/components/Header";
import { useRouter } from "next/router";

const Placeholder = ({ ratio }) => {
  const placeholderStyle = {
    width: "100%",
    paddingTop: `${ratio * 100}%`,
    borderRadius: "10px",
    backgroundColor: "#808080",
  };

  return <div style={placeholderStyle} />;
};

export default function Home() {
  const [data, setData] = useState([]);
  const [name, setName] = useState(null);
  const [page, setPage] = useState(0);
  const [count, setCount] = useState(null);
  const [loading, setLoading] = useState(null);
  const [selectedImage, setSelectedImage] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const router = useRouter();

  const handleImageLoad = () => {
    setIsLoading(false);
  };

  const fetchData = async () => {
    setLoading(true);
    try {
      const response = await axios.get("https://appsearch.cloud/items", {
        params: {
          query: name,
          page: page,
          limit: 100,
        },
      });
      const randomizedData = response.data.data.sort(() => Math.random() - 0.5);
      setCount(response.data.total);
      setData((prev = []) => [...prev, ...randomizedData]);
      setPage((prevPage) => prevPage + 1);
    } catch (error) {
      console.error("Error fetching data:", error);
    } finally {
      setLoading(false);
    }
  };

  const clearData = () => {
    setPage(0);
    setData([]);
  };

  useEffect(() => {
    const queryString = window.location.search;
    const queryParams = new URLSearchParams(queryString);
    const queryName = queryParams.get("q");

    // Check if query name exists in the website link
    if (queryName) {
      // Decode the query name if it's encoded
      const decodedName = decodeURIComponent(queryName);
      // Set the name state with the query name
      setName(decodedName);
    } else {
      const { name } = getRandomItem(values);
      setName(name);
      const query = { ...router.query, q: encodeURIComponent(name) };
      router.replace({ query }, undefined, { shallow: true });
    }
  }, []);

  useEffect(() => {
    if (!name) {
      return;
    }
    fetchData();
  }, [name]);

  const handleScroll = () => {
    if (data?.length >= count) {
      return;
    }
    const threshold = 200; // Adjust this value according to your preference
    if (
      document.documentElement.scrollHeight -
        (window.innerHeight + document.documentElement.scrollTop) >
        threshold ||
      loading
    ) {
      return;
    }
    fetchData();
  };

  useEffect(() => {
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, [loading]);

  const openModal = (data) => {
    setSelectedImage(data);
    setIsLoading(true);
  };

  const closeModal = () => {
    setSelectedImage(null);
    setIsLoading(false);
  };

  return (
    <main className="flex w-full min-h-screen flex-col items-center justify-between pt-[74px] px-[10px]">
      <Header
        name={name}
        count={count}
        length={data?.length}
        setName={setName}
        clearData={clearData}
        loading={loading}
        fetch={fetchData}
        setCount={setCount}
      />
      {selectedImage && (
        <div
          className="fixed top-0 left-0 w-full h-full flex justify-center z-50 bg-black bg-opacity-75"
          onClick={closeModal}
        >
          <div className="relative w-full h-full flex justify-center items-center">
            {isLoading && (
              <button
                disabled
                type="button"
                class="py-2.5 px-5 me-2 text-sm font-medium text-gray-900 bg-white rounded-lg border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-2 focus:ring-blue-700 focus:text-blue-700 dark:bg-gray-800 dark:text-gray-400 dark:border-gray-600 dark:hover:text-white dark:hover:bg-gray-700 inline-flex items-center"
              >
                <svg
                  aria-hidden="true"
                  role="status"
                  class="inline w-4 h-4 me-3 text-gray-200 animate-spin dark:text-gray-600"
                  viewBox="0 0 100 101"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z"
                    fill="currentColor"
                  />
                  <path
                    d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z"
                    fill="#1C64F2"
                  />
                </svg>
                Loading...
              </button>
            )}
            <img
              src={`https://cdn.midjourney.com/${selectedImage?.objectId}.webp`}
              alt="Full size"
              className={`h-[100vh] w-full object-contain ${
                isLoading ? "hidden" : ""
              }`}
              onLoad={handleImageLoad}
            />
            <div className="absolute bottom-0 left-0 w-full">
              <div className="bg-gray-900 text-white text-center p-3 w-full">
                {selectedImage?.prompt}
              </div>
            </div>
            <button
              className="absolute top-4 right-4 text-white"
              onClick={closeModal}
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="h-12 w-12"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
          </div>
        </div>
      )}
      {data ? (
        <ResponsiveMasonry
          className="w-full"
          columnsCountBreakPoints={{ 350: 1, 500: 2, 800: 3, 1000: 5 }}
        >
          <Masonry gutter="10px">
            {data.map((item) => (
              <div
                key={item.objectId}
                style={{ position: "relative" }}
                className="pointer-events-none sm:pointer-events-auto"
                onClick={() => openModal(item)}
              >
                <Placeholder ratio={item?.ratio} />
                <img
                  src={`https://cdn.midjourney.com/${item?.objectId}_384_N.webp`}
                  alt={item.prompt}
                  referrerPolicy="no-referrer"
                  style={{
                    position: "absolute",
                    borderRadius: "10px",
                    cursor: "pointer",
                    top: 0,
                    left: 0,
                    width: "100%",
                    height: "100%",
                    objectFit: "cover",
                    opacity: 0, // Initially hide the image
                    transition: "opacity 0.5s ease", // Add transition for smooth appearance
                  }}
                  onLoad={(e) => {
                    e.target.style.opacity = 1; // Once image is loaded, make it visible
                  }}
                />
              </div>
            ))}
          </Masonry>
        </ResponsiveMasonry>
      ) : (
        <p>Loading...</p>
      )}
    </main>
  );
}
