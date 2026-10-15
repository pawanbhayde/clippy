import React from "react";

export interface ImageProps extends React.ImgHTMLAttributes<HTMLImageElement> {
  fill?: boolean;
  priority?: boolean;
}

export function Image({
  fill,
  priority,
  className = "",
  alt = "",
  loading,
  decoding = "async",
  ...props
}: ImageProps) {
  const fillClasses = fill ? "absolute inset-0 w-full h-full" : "";
  const computedLoading = loading ?? (priority ? "eager" : "lazy");

  return (
    <img
      alt={alt}
      loading={computedLoading}
      decoding={decoding}
      className={`${fillClasses} ${className}`.trim()}
      {...props}
    />
  );
}

export default Image;
