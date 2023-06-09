def gen_svg(data, image = nil)
  svg = %{
    <svg
      width="500"
      height="165"
      viewBox="0 0 500 165"
      fill="white"
      xmlns="http://www.w3.org/2000/svg"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      role="img"
      aria-labelledby="descId"
    >
      <title id="titleId"></title>
      <desc id="descId"></desc>

      <style>
        .data {
          font: 400 18px 'Segoe UI', Ubuntu, Sans-Serif;
          animation: fadeInAnimation 0.8s ease-in-out forwards;
        }
      </style>

      <rect
        data-testid="card-bg"
        x="0.5"
        y="0.5"
        rx="4.5"
        height="99%"
        stroke="#1A1B26"
        width="499"
        fill="#1E1E2E"
        stroke-opacity="0"
      />
  }

  if image
    svg += %{
      <clipPath id="round" clipPathUnits="objectBoundingBox">
        <circle cx=".5" cy=".5" r=".5" />
      </clipPath>

      <image
        id="image"
        xlink:href="/#{image}"
        x="370"
        y="30"
        height="100"
        width="100"
        clip-path="url(#round)"
      />
    }
  end

  data.each_with_index do |key, value, index|
    svg += %{
        <g
          transform="translate(25, #{45 + index * 30})"
        >
          <text
            x="0"
            y="0"
            class="data"
            data-testid="header"
          >#{key}: #{value}</text>
        </g>
    }
  end

  svg += %{
      </svg>
  }

  svg
end
