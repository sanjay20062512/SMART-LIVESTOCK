import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-lg text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[#087F73] focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0 cursor-pointer active:scale-[0.98]",
  {
    variants: {
      variant: {
        default: "bg-[#12304A] text-white hover:bg-[#0d2336] shadow-sm",
        primary: "bg-[#12304A] text-white hover:bg-[#0d2336] shadow-sm",
        teal: "bg-[#087F73] text-white hover:bg-[#06655c] shadow-sm",
        secondary: "bg-white text-[#18232B] border border-[#E4EAF0] hover:bg-[#F7F9FB] shadow-xs",
        soft: "bg-[#EAF3FB] text-[#1769AA] hover:bg-[#d8eaf8]",
        softMint: "bg-[#EAF7F2] text-[#087F73] hover:bg-[#d5f0e6]",
        warning: "bg-[#FFF5D6] text-[#B87A04] border border-[#D99A18]/30 hover:bg-[#faecc2]",
        destructive: "bg-[#C94343] text-white hover:bg-[#b03737] shadow-sm",
        outline: "border border-[#E4EAF0] bg-transparent text-[#18232B] hover:bg-[#F7F9FB]",
        ghost: "hover:bg-[#EAF3FB] text-[#18232B] hover:text-[#1769AA]",
        link: "text-[#1769AA] underline-offset-4 hover:underline",
      },
      size: {
        default: "h-9 px-3.5 py-2",
        sm: "h-8 rounded-md px-2.5 text-xs",
        lg: "h-10 rounded-lg px-5 text-base",
        icon: "h-9 w-9",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button"
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = "Button"

export { Button, buttonVariants }
