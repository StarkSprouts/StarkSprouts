type ButtonProps = {
  onPress?: () => void;
  label?: string;
  children?: React.ReactNode;
};

export const StyledButton = (props: ButtonProps) => {
  return (
    <button
      onClick={props.onPress}
      className="bg-blue-500 flex justify-center hover:bg-blue-700 text-white font-bold py-2 px-4 rounded w-32"
    >
      {props.label || props.children}
    </button>
  );
};
