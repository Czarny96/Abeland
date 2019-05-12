varying mediump vec2 var_texcoord0;

uniform lowp sampler2D texture_sampler;
uniform lowp vec4 tint;
uniform lowp vec4 colorize;
uniform lowp vec4 brightness; // only 'r' is used - we can pass only vec4


void main()
{
    // apply tint
    lowp vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
    vec4 color = texture2D(texture_sampler, var_texcoord0.xy) * tint_pm;
    
    lowp vec3 output = vec3(color);

    // apply color
    output.r *= colorize.r;
    output.g *= colorize.g;
    output.b *= colorize.b;

    // apply brightness
    output.r *= brightness.r;
    output.g *= brightness.r;
    output.b *= brightness.r;

    
    gl_FragColor = vec4(output.rgb, color.a);
}