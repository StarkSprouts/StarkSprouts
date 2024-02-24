export default function Plant({ plantType }: { plantType: string }) {
  return <div className="border border-white w-10 h-10 m-1">{plantType}</div>;
}
