import React, { useState, useEffect } from "react";
import axios from "axios";
import { useDebounce } from "use-debounce";
import { useRouter } from "next/router";

export const Header = ({
  name,
  count,
  length,
  setName,
  clearData,
  loading,
  fetch,
}) => {
  const [searchResults, setSearchResults] = useState([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [debouncedValue] = useDebounce(searchQuery, 500);
  const [selectedIndex, setSelectedIndex] = useState(-1);
  const router = useRouter();

  const handleKeyDown = (e) => {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setSelectedIndex((prevIndex) =>
        prevIndex < searchResults.length - 1 ? prevIndex + 1 : prevIndex
      );
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setSelectedIndex((prevIndex) =>
        prevIndex > 0 ? prevIndex - 1 : prevIndex
      );
    } else if (e.key === "Enter") {
      e.preventDefault();
      if (selectedIndex !== -1) {
        const selectedValue = searchResults[selectedIndex];
        if (name === selectedValue) {
          clearData();
          setSearchQuery("");
          setSearchResults([]);
          setSelectedIndex(-1);
          fetch();
          return;
        }
        clearData();
        setSearchQuery("");
        setSearchResults([]);
        setName(selectedValue);
        setSelectedIndex(-1);
        const query = {
          ...router.query,
          q: encodeURIComponent(selectedValue),
        };
        router.replace({ query }, undefined, { shallow: true });
      } else {
        if (name === e.target.value) {
          clearData();
          setSearchQuery("");
          setSearchResults([]);
          fetch();
          return;
        }
        clearData();
        setSearchQuery("");
        setSearchResults([]);
        setName(e.target.value);
        const query = {
          ...router.query,
          q: encodeURIComponent(e.target.value),
        };
        router.replace({ query }, undefined, { shallow: true });
      }
    }
  };

  const fetchSearchResults = async (query) => {
    if (!query) {
      setSearchResults([]);
      return;
    }
    try {
      const response = await axios.get(
        `https://appsearch.cloud/search?query=${query}&limit=10`
      );
      setSearchResults(response.data.suggestions);
    } catch (error) {
      console.error("Error fetching search results:", error);
    }
  };

  const handleInputChange = (event) => {
    const value = event.target.value;
    setSearchQuery(value);
  };

  useEffect(() => {
    fetchSearchResults(debouncedValue);
  }, [debouncedValue]);

  return (
    <nav className="bg-gray-900 h-[62px] fixed w-full z-20 top-0 start-0 border-b border-gray-600">
      <div className="max-w-screen-xl h-full flex flex-wrap items-center sm:justify-between justify-center mx-auto p-3">
        <div
          onClick={() => {
            const urlWithoutParams =
              window.location.origin + window.location.pathname;
            window.location.href = urlWithoutParams;
          }}
          className="flex cursor-pointer md:block hidden items-center space-x-3 rtl:space-x-reverse"
        >
          <span className="self-center text-2xl font-semibold whitespace-nowrap text-white">
            Midjourney Showcase
          </span>
        </div>
        {name && !loading ? (
          <p
            onClick={() => {
              const urlWithoutParams =
                window.location.origin + window.location.pathname;
              window.location.href = urlWithoutParams;
            }}
            className="cursor-pointer"
          >
            <b>
              {name
                ?.split(" ")
                .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
                .join(" ")}
            </b>{" "}
            {length} of {count}
          </p>
        ) : (
          <p>Loading...</p>
        )}
        <div className="relative sm:block hidden">
          <div className="absolute inset-y-0 start-0 flex items-center ps-3 pointer-events-none">
            <svg
              className="w-4 h-4 text-gray-400"
              aria-hidden="true"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 20 20"
            >
              <path
                stroke="currentColor"
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth="2"
                d="m19 19-4-4m0-7A7 7 0 1 1 1 8a7 7 0 0 1 14 0Z"
              />
            </svg>
            <span className="sr-only">Search icon</span>
          </div>
          <input
            type="text"
            id="search-navbar"
            className="block w-full p-2 ps-10 text-sm border rounded-lg bg-gray-700 border-gray-600 placeholder-gray-400 text-white focus:ring-blue-500 focus:border-blue-500"
            placeholder="Search..."
            value={searchQuery}
            onChange={handleInputChange}
            onKeyDown={handleKeyDown}
          />
          {searchResults.length > 0 && (
            <div className="absolute z-10 w-full mt-1 bg-gray-800 border border-gray-700 rounded-lg shadow-lg">
              {searchResults.map((result, index) => (
                <div
                  key={index}
                  onClick={() => {
                    if (name === result) {
                      clearData();
                      setSearchQuery("");
                      setSearchResults([]);
                      fetch();
                      return;
                    }
                    clearData();
                    setSearchQuery("");
                    setSearchResults([]);
                    setName(result);
                    const query = {
                      ...router.query,
                      q: encodeURIComponent(result),
                    };
                    router.replace({ query }, undefined, { shallow: true });
                  }}
                  className={`p-2 hover:bg-gray-700 truncate cursor-pointer ${
                    selectedIndex === index ? "bg-blue-500 text-white" : ""
                  }`}
                >
                  {result}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </nav>
  );
};
