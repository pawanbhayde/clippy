export default function FloatingChatButton() {
  return (
      <button
        data-slot="button"
        type="button"
        className="ring-ring/10 outline-ring/50 dark:ring-ring/20 dark:outline-ring/40 inline-flex items-center justify-center gap-2 text-sm font-medium whitespace-nowrap focus-visible:ring-4 focus-visible:outline-1 disabled:pointer-events-none disabled:opacity-50 aria-invalid:focus-visible:ring-0 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 ring-0! transition-all border-app-primary hover:bg-foreground/20 focus-visible:bg-foreground/20 disabled:bg-app-primary border has-[>svg]:px-3 bg-app-primary fixed right-4 bottom-5 z-20 size-10 rounded-full p-0 text-white shadow-xl backdrop-blur-md hover:scale-95 hover:opacity-90 hover:shadow-lg active:scale-80 active:opacity-50"
      >
        <svg
          width="24"
          height="24"
          viewBox="0 0 24 24"
          fill="transparent"
          className="caret-icon caret-icon-message-circle-2-solid-icon size-5"
        >
          <path
            fill="currentColor"
            fillRule="evenodd"
            d="M2 12C2 6.477 6.477 2 12 2s10 4.477 10 10-4.477 10-10 10a10 10 0 0 1-3.76-.732l-.225-.089-.005.001-.183.03-3.587.597c-.16.027-.34.057-.496.069-.17.012-.44.017-.727-.106a1.5 1.5 0 0 1-.787-.787 1.5 1.5 0 0 1-.106-.727c.012-.156.042-.336.069-.496l.005-.03.593-3.557.029-.183v-.005l-.004-.014-.084-.21A10 10 0 0 1 2 12"
            clipRule="evenodd"
          ></path>
        </svg>
      </button>
  );
}
