import * as React from "react"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const badgeVariants = cva(
  "inline-flex items-center rounded-full border px-2 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 tracking-wide",
  {
    variants: {
      variant: {
        default:
          "border-transparent bg-[#12304A] text-white shadow-xs",
        secondary:
          "border-transparent bg-[#EAF3FB] text-[#1769AA]",
        teal:
          "border-transparent bg-[#EAF7F2] text-[#087F73]",
        low:
          "border-emerald-200 bg-[#EAF7F2] text-[#16845B]",
        moderate:
          "border-amber-200 bg-[#FFF5D6] text-[#B87A04]",
        high:
          "border-orange-200 bg-[#FFEDD5] text-[#C2410C]",
        critical:
          "border-rose-200 bg-[#FDECEC] text-[#C94343]",
        destructive:
          "border-transparent bg-[#C94343] text-white shadow-xs",
        outline:
          "border-[#E4EAF0] text-[#18232B] bg-white",
      },
    },
    defaultVariants: {
      variant: "default",
    },
  }
)

export interface BadgeProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof badgeVariants> {}

function Badge({ className, variant, ...props }: BadgeProps) {
  return (
    <div className={cn(badgeVariants({ variant }), className)} {...props} />
  )
}

export { Badge, badgeVariants }
